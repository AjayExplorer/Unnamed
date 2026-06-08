import 'package:cloud_firestore/cloud_firestore.dart';
import '../../request_letter/faculty/models/faculty_model.dart';
import '../models/bus_model.dart';
import '../models/tracking_model.dart';

class BusTrackingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Driver Queries ---

  // Get all drivers from 'faculty' collection
  Future<List<Faculty>> getAllDrivers() async {
    try {
      final snapshot = await _firestore
          .collection('faculty')
          .where('role', isEqualTo: 'driver')
          .get();

      return snapshot.docs
          .map((doc) => Faculty.fromMap({...doc.data(), 'facultyId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Error fetching drivers: $e');
    }
  }

  // Register driver (saves to 'faculty' collection)
  Future<void> registerDriver(Faculty driver) async {
    try {
      // Plain text password as per project design
      await _firestore
          .collection('faculty')
          .doc(driver.facultyId)
          .set(driver.toMap());
    } catch (e) {
      throw Exception('Error registering driver: $e');
    }
  }

  // Update driver details
  Future<void> updateDriverProfile(
    String driverId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('faculty').doc(driverId).update(data);
    } catch (e) {
      throw Exception('Error updating driver profile: $e');
    }
  }

  // --- Bus Queries ---

  // Register static bus info
  Future<void> registerBus(Bus bus) async {
    try {
      await _firestore.collection('buses').doc(bus.busId).set(bus.toMap());

      // Update the assigned driver profile as well with the bus ID
      await _firestore.collection('faculty').doc(bus.driverId).update({
        'assignedBusId': bus.busId,
      });

      // Initialize an inactive tracking record in bus_tracking
      final initialTracking = BusTrackingState(
        busId: bus.busId,
        driverId: bus.driverId,
        latitude: bus.route.source.latitude,
        longitude: bus.route.source.longitude,
        currentSpeed: 0.0,
        timestamp: DateTime.now(),
        currentStop: bus.route.source.name,
        nextStop: bus.route.stops.isNotEmpty
            ? bus.route.stops.first.name
            : bus.route.destination.name,
        distanceToNextStop: 0.0,
        eta: '--',
        trackingActive: false,
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
        stopsStatus: [
          RouteStopStatus(
            name: bus.route.source.name,
            latitude: bus.route.source.latitude,
            longitude: bus.route.source.longitude,
            status: 'current',
          ),
          ...bus.route.stops.map(
            (s) => RouteStopStatus(
              name: s.name,
              latitude: s.latitude,
              longitude: s.longitude,
              status: 'upcoming',
            ),
          ),
          RouteStopStatus(
            name: bus.route.destination.name,
            latitude: bus.route.destination.latitude,
            longitude: bus.route.destination.longitude,
            status: 'upcoming',
          ),
        ],
      );

      await _firestore
          .collection('bus_tracking')
          .doc(bus.busId)
          .set(initialTracking.toMap());
    } catch (e) {
      throw Exception('Error registering bus: $e');
    }
  }

  // Update an existing bus
  Future<void> updateBus(Bus bus, {String? previousDriverId}) async {
    try {
      await _firestore.collection('buses').doc(bus.busId).set(bus.toMap());

      // If driver changed, clear old driver's assignedBusId
      if (previousDriverId != null && previousDriverId != bus.driverId) {
        await _firestore.collection('faculty').doc(previousDriverId).update({
          'assignedBusId': '',
        });
      }

      // Update new driver's assignedBusId
      await _firestore.collection('faculty').doc(bus.driverId).update({
        'assignedBusId': bus.busId,
      });

      // Re-initialize tracking state with updated route
      final updatedTracking = BusTrackingState(
        busId: bus.busId,
        driverId: bus.driverId,
        latitude: bus.route.source.latitude,
        longitude: bus.route.source.longitude,
        currentSpeed: 0.0,
        timestamp: DateTime.now(),
        currentStop: bus.route.source.name,
        nextStop: bus.route.stops.isNotEmpty
            ? bus.route.stops.first.name
            : bus.route.destination.name,
        distanceToNextStop: 0.0,
        eta: '--',
        trackingActive: false,
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
        stopsStatus: [
          RouteStopStatus(
            name: bus.route.source.name,
            latitude: bus.route.source.latitude,
            longitude: bus.route.source.longitude,
            status: 'current',
          ),
          ...bus.route.stops.map(
            (s) => RouteStopStatus(
              name: s.name,
              latitude: s.latitude,
              longitude: s.longitude,
              status: 'upcoming',
            ),
          ),
          RouteStopStatus(
            name: bus.route.destination.name,
            latitude: bus.route.destination.latitude,
            longitude: bus.route.destination.longitude,
            status: 'upcoming',
          ),
        ],
      );

      await _firestore
          .collection('bus_tracking')
          .doc(bus.busId)
          .set(updatedTracking.toMap());
    } catch (e) {
      throw Exception('Error updating bus: $e');
    }
  }

  // Delete a bus and clean up associated data
  Future<void> deleteBus(String busId) async {
    try {
      // Get the bus first to find the assigned driver
      final busDoc = await _firestore.collection('buses').doc(busId).get();
      if (busDoc.exists && busDoc.data() != null) {
        final driverId = busDoc.data()!['driverId'] as String?;
        if (driverId != null && driverId.isNotEmpty) {
          await _firestore.collection('faculty').doc(driverId).update({
            'assignedBusId': '',
          });
        }
      }

      // Delete bus document
      await _firestore.collection('buses').doc(busId).delete();

      // Delete tracking document
      await _firestore.collection('bus_tracking').doc(busId).delete();
    } catch (e) {
      throw Exception('Error deleting bus: $e');
    }
  }

  // Fetch all registered buses
  Future<List<Bus>> getAllBuses() async {
    try {
      final snapshot = await _firestore.collection('buses').get();
      return snapshot.docs
          .map((doc) => Bus.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching buses: $e');
    }
  }

  // Fetch a single bus profile
  Future<Bus?> getBus(String busId) async {
    try {
      final doc = await _firestore.collection('buses').doc(busId).get();
      if (doc.exists && doc.data() != null) {
        return Bus.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching bus info: $e');
    }
  }

  // --- Real-time Location Updates ---

  // Stream of tracking details for a specific bus
  Stream<BusTrackingState?> streamBusTracking(String busId) {
    return _firestore.collection('bus_tracking').doc(busId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return BusTrackingState.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Stream of all active tracking buses (for student list updates in real time)
  Stream<List<BusTrackingState>> streamAllActiveTracking() {
    return _firestore.collection('bus_tracking').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BusTrackingState.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update tracking coordinates and state
  Future<void> updateTrackingState(BusTrackingState state) async {
    try {
      final updatedState = BusTrackingState(
        busId: state.busId,
        driverId: state.driverId,
        latitude: state.latitude,
        longitude: state.longitude,
        currentSpeed: state.currentSpeed,
        timestamp: state.timestamp,
        currentStop: state.currentStop,
        nextStop: state.nextStop,
        distanceToNextStop: state.distanceToNextStop,
        eta: state.eta,
        trackingActive: state.trackingActive,
        stopsStatus: state.stopsStatus,
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      );

      await _firestore
          .collection('bus_tracking')
          .doc(state.busId)
          .set(updatedState.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating tracking state: $e');
    }
  }

  // Turn tracking on or off
  Future<void> setTrackingActive(String busId, bool active) async {
    try {
      await _firestore.collection('bus_tracking').doc(busId).update({
        'trackingActive': active,
      });
    } catch (e) {
      throw Exception('Error setting tracking status: $e');
    }
  }

  // Cleanup bus tracking records that haven't been updated for 4 hours
  Future<void> cleanExpiredTracking() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore.collection('bus_tracking').get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestampVal = data['timestamp'];
        DateTime? lastTime;
        if (timestampVal is Timestamp) {
          lastTime = timestampVal.toDate();
        } else if (timestampVal is String) {
          lastTime = DateTime.tryParse(timestampVal);
        }
        if (lastTime != null) {
          if (now.difference(lastTime).inHours >= 4) {
            await doc.reference.delete();
          }
        }
      }
    } catch (e) {
      // Ignore
    }
  }
}
