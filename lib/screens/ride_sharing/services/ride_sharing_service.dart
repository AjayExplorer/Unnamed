import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_offer.dart';
import '../models/ride_request.dart';

class RideSharingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _ridesCol = 'ride_offers';
  static const String _requestsCol = 'ride_requests';

  // ────────────────────────────────────────────────────────────────────
  // RIDE OFFERS
  // ────────────────────────────────────────────────────────────────────

  /// Create a new ride offer.
  Future<String> createRideOffer(RideOffer offer) async {
    final ref = await _db.collection(_ridesCol).add(offer.toMap());
    return ref.id;
  }

  /// Real-time stream of ACTIVE rides, excluding the current user's own rides.
  /// Client-side filters out expired rides (seats == 0 or datetime passed).
  Stream<List<RideOffer>> streamActiveRides({required String excludeUserId}) {
    return _db
        .collection(_ridesCol)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => RideOffer.fromSnapshot(doc))
          .where((ride) =>
              ride.creatorId != excludeUserId && // not own ride
              (!ride.isExpired || ride.participantIds.contains(excludeUserId))) // include if not expired OR user is participant
          .toList();
      // Sort client-side to avoid Firestore composite index requirements
      list.sort((a, b) => a.rideDateTime.compareTo(b.rideDateTime));
      return list;
    });
  }

  /// Real-time stream of rides created by [userId].
  Stream<List<RideOffer>> streamMyRides({required String userId}) {
    return _db
        .collection(_ridesCol)
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => RideOffer.fromSnapshot(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Mark rides whose datetime has passed or seats=0 as expired.
  Future<void> markExpiredRides() async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final expired = await _db
          .collection(_ridesCol)
          .where('status', isEqualTo: 'active')
          .where('rideDateTime', isLessThan: now)
          .get();

      final batch = _db.batch();
      for (final doc in expired.docs) {
        batch.update(doc.reference, {'status': 'expired'});
        // Also cancel pending requests for expired rides
        final requests = await _db
            .collection(_requestsCol)
            .where('rideId', isEqualTo: doc.id)
            .where('status', isEqualTo: 'pending')
            .get();
        for (final req in requests.docs) {
          batch.update(req.reference, {'status': 'rideCancelled'});
        }
      }
      await batch.commit();
    } catch (_) {
      // Best-effort; don't crash the UI
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // RIDE REQUESTS
  // ────────────────────────────────────────────────────────────────────

  /// Submit a join request from [requesterId] for [rideId].
  /// Returns null on success, or an error message string.
  Future<String?> requestToJoin({
    required String rideId,
    required String requesterId,
    required String requesterName,
    String requesterPhotoUrl = '',
    String requesterPhone = '',
  }) async {
    try {
      // Check if already requested
      final existing = await _db
          .collection(_requestsCol)
          .where('rideId', isEqualTo: rideId)
          .where('requesterId', isEqualTo: requesterId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return 'You have already sent a request for this ride.';
      }

      // Check seat availability
      final rideDoc = await _db.collection(_ridesCol).doc(rideId).get();
      if (!rideDoc.exists) return 'Ride not found.';
      final ride = RideOffer.fromSnapshot(rideDoc);
      if (ride.availableSeats <= 0) return 'No seats available.';
      if (ride.isExpired) return 'This ride has expired or is no longer active.';

      await _db.collection(_requestsCol).add(
            RideRequest(
              rideId: rideId,
              requesterId: requesterId,
              requesterName: requesterName,
              requesterPhotoUrl: requesterPhotoUrl,
              requesterPhone: requesterPhone,
              status: RideRequestStatus.pending,
              createdAt: DateTime.now(),
            ).toMap(),
          );
      return null; // success
    } catch (e) {
      return 'Failed to send request: $e';
    }
  }

  /// Stream of requests made by [requesterId].
  Stream<List<RideRequest>> streamMyRequests({required String requesterId}) {
    return _db
        .collection(_requestsCol)
        .where('requesterId', isEqualTo: requesterId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => RideRequest.fromSnapshot(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream of ALL requests for rides owned by [ownerId].
  /// Returns combined stream via Firestore collection group query equivalent.
  Stream<List<RideRequest>> streamRequestsForMyRides({
    required String ownerId,
    required List<String> myRideIds,
  }) {
    if (myRideIds.isEmpty) {
      return Stream.value([]);
    }
    // Firestore 'whereIn' supports up to 30 elements
    final ids = myRideIds.take(30).toList();
    return _db
        .collection(_requestsCol)
        .where('rideId', whereIn: ids)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => RideRequest.fromSnapshot(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream of a specific request by its [requestId] (for real-time status).
  Stream<RideRequest?> streamRequest(String requestId) {
    return _db
        .collection(_requestsCol)
        .doc(requestId)
        .snapshots()
        .map((doc) => doc.exists ? RideRequest.fromSnapshot(doc) : null);
  }

  /// Approve a join request: update status, decrement seats, add to participants.
  Future<void> approveRequest({
    required String requestId,
    required String rideId,
    required String requesterId,
  }) async {
    final batch = _db.batch();

    // Update request status and set approvedAt timestamp
    final reqRef = _db.collection(_requestsCol).doc(requestId);
    batch.update(reqRef, {
      'status': 'approved',
      'approvedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Decrement available seats and add participant
    final rideRef = _db.collection(_ridesCol).doc(rideId);
    batch.update(rideRef, {
      'availableSeats': FieldValue.increment(-1),
      'participantIds': FieldValue.arrayUnion([requesterId]),
    });

    await batch.commit();

    // If availableSeats hits 0 after this, mark ride as expired
    final rideDoc = await rideRef.get();
    if (rideDoc.exists) {
      final seats = (rideDoc.data()?['availableSeats'] as num?)?.toInt() ?? 1;
      if (seats <= 0) {
        // We no longer mark the status as 'expired' here so the ride stays visible
        // for approved participants in their "Find a Ride" tab.
        // The background markExpiredRides() will still clean it up when datetime passes.
        
        // Cancel all remaining pending requests
        final pending = await _db
            .collection(_requestsCol)
            .where('rideId', isEqualTo: rideId)
            .where('status', isEqualTo: 'pending')
            .get();
        final b2 = _db.batch();
        for (final d in pending.docs) {
          b2.update(d.reference, {'status': 'rideCancelled'});
        }
        await b2.commit();
      }
    }
  }

  /// Reject a join request.
  Future<void> rejectRequest(String requestId) async {
    await _db.collection(_requestsCol).doc(requestId).update({'status': 'rejected'});
  }

  // ────────────────────────────────────────────────────────────────────
  // RIDE CANCELLATION / DELETION
  // ────────────────────────────────────────────────────────────────────

  /// Cancel a ride: set status→cancelled, propagate to all related requests.
  Future<void> cancelRide(String rideId) async {
    // Update ride status
    await _db.collection(_ridesCol).doc(rideId).update({'status': 'cancelled'});

    // Update all pending and approved requests to rideCancelled
    final requests = await _db
        .collection(_requestsCol)
        .where('rideId', isEqualTo: rideId)
        .get();

    if (requests.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final doc in requests.docs) {
        final currentStatus = doc.data()['status'] as String?;
        if (currentStatus == 'pending' || currentStatus == 'approved') {
          batch.update(doc.reference, {'status': 'rideCancelled'});
        }
      }
      await batch.commit();
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────

  /// Fetch a single ride offer by ID (one-time read).
  Future<RideOffer?> getRideById(String rideId) async {
    final doc = await _db.collection(_ridesCol).doc(rideId).get();
    if (!doc.exists) return null;
    return RideOffer.fromSnapshot(doc);
  }

  /// Real-time stream of a single ride offer.
  Stream<RideOffer?> streamRideById(String rideId) {
    return _db
        .collection(_ridesCol)
        .doc(rideId)
        .snapshots()
        .map((doc) => doc.exists ? RideOffer.fromSnapshot(doc) : null);
  }
}
