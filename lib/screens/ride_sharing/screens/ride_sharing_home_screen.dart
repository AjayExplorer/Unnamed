import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';
import '../models/ride_offer.dart';
import '../models/ride_request.dart';
import '../services/ride_sharing_service.dart';
import 'create_ride_offer_screen.dart';

class RideSharingHomeScreen extends StatefulWidget {
  const RideSharingHomeScreen({super.key});

  @override
  State<RideSharingHomeScreen> createState() => _RideSharingHomeScreenState();
}

class _RideSharingHomeScreenState extends State<RideSharingHomeScreen>
    with SingleTickerProviderStateMixin {
  static const _teal = Color(0xFF2AADC4);

  late final TabController _tabController;
  final _service = RideSharingService();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Best-effort cleanup of rides whose time already passed
    _service.markExpiredRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>().currentStudent;
    final studentId = student?.id ?? '';
    final studentName = student?.fullName ?? 'Student';
    final studentPhotoUrl = student?.photoUrl ?? '';
    final studentPhone = student?.phoneNumber ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FB),
      appBar: AppBar(
        title: const Text(
          'Carpools',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.trim().toLowerCase()),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search by Origin / Destination',
                    hintStyle:
                        const TextStyle(color: Colors.black45, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF1A8FA5)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Find a Ride'),
                  Tab(text: 'Requests'),
                  Tab(text: 'My Rides'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FindARideTab(
            service: _service,
            currentStudentId: studentId,
            currentStudentName: studentName,
            currentStudentPhotoUrl: studentPhotoUrl,
            currentStudentPhone: studentPhone,
            searchQuery: _searchQuery,
          ),
          _RequestsTab(
            service: _service,
            currentStudentId: studentId,
          ),
          _MyRidesTab(
            service: _service,
            currentStudentId: studentId,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateRideOfferScreen()),
          );
          if (result == true) {
            _service.markExpiredRides();
          }
        },
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        tooltip: 'Create Ride Offer',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Find a Ride
// ─────────────────────────────────────────────────────────────────────────────

class _FindARideTab extends StatelessWidget {
  const _FindARideTab({
    required this.service,
    required this.currentStudentId,
    required this.currentStudentName,
    required this.currentStudentPhotoUrl,
    required this.currentStudentPhone,
    required this.searchQuery,
  });

  final RideSharingService service;
  final String currentStudentId;
  final String currentStudentName;
  final String currentStudentPhotoUrl;
  final String currentStudentPhone;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RideOffer>>(
      stream: service.streamActiveRides(excludeUserId: currentStudentId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final allRides = snap.data ?? [];
        final rides = searchQuery.isEmpty
            ? allRides
            : allRides.where((r) {
                final q = searchQuery;
                return r.source.toLowerCase().contains(q) ||
                    r.destination.toLowerCase().contains(q);
              }).toList();

        if (rides.isEmpty) {
          return _EmptyState(
            icon: Icons.directions_car_outlined,
            message: 'No active rides available.\nCreate one using the + button!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rides.length,
          itemBuilder: (ctx, i) => _RideCard(
            ride: rides[i],
            service: service,
            currentStudentId: currentStudentId,
            currentStudentName: currentStudentName,
            currentStudentPhotoUrl: currentStudentPhotoUrl,
            currentStudentPhone: currentStudentPhone,
            showRequestButton: true,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Requests (two sections: Incoming + My Join Requests)
// ─────────────────────────────────────────────────────────────────────────────

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.service,
    required this.currentStudentId,
  });

  final RideSharingService service;
  final String currentStudentId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ── Section A: Incoming requests to the student's own rides ──
        _IncomingRequestsSection(
          service: service,
          currentStudentId: currentStudentId,
        ),
        const SizedBox(height: 16),
        // ── Section B: This student's own sent join requests ──
        _MyJoinRequestsSection(
          service: service,
          currentStudentId: currentStudentId,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section A — Incoming Requests (ride-owner view)
// ─────────────────────────────────────────────────────────────────────────────

class _IncomingRequestsSection extends StatelessWidget {
  const _IncomingRequestsSection({
    required this.service,
    required this.currentStudentId,
  });

  final RideSharingService service;
  final String currentStudentId;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.inbox_rounded, color: _teal, size: 18),
            const SizedBox(width: 6),
            const Text(
              'Incoming Requests',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<RideOffer>>(
          stream: service.streamMyRides(userId: currentStudentId),
          builder: (context, ridesSnap) {
            if (ridesSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final myRides = ridesSnap.data ?? [];
            final myRideIds = myRides.map((r) => r.id ?? '').toList();

            if (myRideIds.isEmpty) {
              return _SectionEmptyHint(
                icon: Icons.directions_car_outlined,
                message: 'You have no ride offers.',
              );
            }

            return StreamBuilder<List<RideRequest>>(
              stream: service.streamRequestsForMyRides(
                  ownerId: currentStudentId, myRideIds: myRideIds),
              builder: (context, reqSnap) {
                if (reqSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (reqSnap.hasError) {
                  return Center(child: Text('Error: ${reqSnap.error}'));
                }

                final allRequests = reqSnap.data ?? [];

                if (allRequests.isEmpty) {
                  return _SectionEmptyHint(
                    icon: Icons.people_outline,
                    message: 'No join requests yet.',
                  );
                }

                // Group requests by rideId
                final grouped = <String, List<RideRequest>>{};
                for (final req in allRequests) {
                  grouped.putIfAbsent(req.rideId, () => []).add(req);
                }

                return Column(
                  children: grouped.entries.map((entry) {
                    final rideId = entry.key;
                    final ride = myRides.firstWhere(
                      (r) => r.id == rideId,
                      orElse: () => RideOffer(
                        creatorId: '',
                        creatorName: '',
                        source: '',
                        destination: rideId,
                        rideDateTime: DateTime.now(),
                        vehicleType: VehicleType.car,
                        totalSeats: 0,
                        availableSeats: 0,
                        createdAt: DateTime.now(),
                      ),
                    );
                    return _RideRequestGroup(
                      ride: ride,
                      requests: entry.value,
                      service: service,
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section B — My Join Requests (requester's outgoing requests)
// ─────────────────────────────────────────────────────────────────────────────

class _MyJoinRequestsSection extends StatelessWidget {
  const _MyJoinRequestsSection({
    required this.service,
    required this.currentStudentId,
  });

  final RideSharingService service;
  final String currentStudentId;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.send_rounded, color: _teal, size: 18),
            const SizedBox(width: 6),
            const Text(
              'My Join Requests',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<RideRequest>>(
          stream: service.streamMyRequests(requesterId: currentStudentId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }

            final allRequests = snap.data ?? [];
            // Filter out auto-expired approvals (3+ days after approval)
            final requests = allRequests
                .where((r) => !r.isExpiredApproval)
                .toList();

            if (requests.isEmpty) {
              return _SectionEmptyHint(
                icon: Icons.send_outlined,
                message: 'You have not sent any join requests.',
              );
            }

            return Column(
              children: requests
                  .map((req) => _MyJoinRequestCard(
                        request: req,
                        service: service,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Join Request Card (requester's own request tracking card)
// ─────────────────────────────────────────────────────────────────────────────

class _MyJoinRequestCard extends StatelessWidget {
  const _MyJoinRequestCard({
    required this.request,
    required this.service,
  });

  final RideRequest request;
  final RideSharingService service;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RideOffer?>(
      stream: service.streamRideById(request.rideId),
      builder: (context, snap) {
        final ride = snap.data;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route header
                if (ride != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.directions_car_rounded,
                          color: _teal, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${ride.source} → ${ride.destination}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(ride.rideDateTime)} at ${_formatTime(ride.rideDateTime)}',
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Creator info (profile photo + phone)
                  Row(
                    children: [
                      _Avatar(
                        photoUrl: ride.creatorPhotoUrl,
                        name: ride.creatorName,
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ride.creatorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            if (ride.creatorPhone.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      size: 11,
                                      color: Color(0xFF6B7280)),
                                  const SizedBox(width: 3),
                                  Text(ride.creatorPhone,
                                      style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 11)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                ],

                // Status chip
                _MyRequestStatusChip(status: request.status),


              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My request status chip (full-width, shows Ride Cancelled prominently)
// ─────────────────────────────────────────────────────────────────────────────

class _MyRequestStatusChip extends StatelessWidget {
  const _MyRequestStatusChip({required this.status});
  final RideRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label, bg, fg) = switch (status) {
      RideRequestStatus.pending => (
          Icons.hourglass_empty_rounded,
          'Pending Approval',
          const Color(0xFFFFF3CD),
          const Color(0xFF856404)
        ),
      RideRequestStatus.approved => (
          Icons.check_circle_rounded,
          'Approved ✓',
          const Color(0xFFD4EDDA),
          const Color(0xFF155724)
        ),
      RideRequestStatus.rejected => (
          Icons.cancel_rounded,
          'Request Rejected',
          const Color(0xFFF8D7DA),
          const Color(0xFF721C24)
        ),
      RideRequestStatus.rideCancelled => (
          Icons.do_not_disturb_on_rounded,
          '⚠️ Ride Cancelled by Creator',
          const Color(0xFFFFE5E5),
          const Color(0xFF9B1C1C)
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — My Rides
// ─────────────────────────────────────────────────────────────────────────────

class _MyRidesTab extends StatelessWidget {
  const _MyRidesTab({
    required this.service,
    required this.currentStudentId,
  });

  final RideSharingService service;
  final String currentStudentId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RideOffer>>(
      stream: service.streamMyRides(userId: currentStudentId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final rides = snap.data ?? [];
        if (rides.isEmpty) {
          return _EmptyState(
            icon: Icons.directions_car_outlined,
            message: 'You have no rides.\nTap + to create a ride offer!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rides.length,
          itemBuilder: (ctx, i) => _MyRideCard(
            ride: rides[i],
            service: service,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIDE CARD (Find a Ride tab) — with profile photo + phone
// ─────────────────────────────────────────────────────────────────────────────

class _RideCard extends StatelessWidget {
  const _RideCard({
    required this.ride,
    required this.service,
    required this.currentStudentId,
    required this.currentStudentName,
    required this.currentStudentPhotoUrl,
    required this.currentStudentPhone,
    required this.showRequestButton,
  });

  final RideOffer ride;
  final RideSharingService service;
  final String currentStudentId;
  final String currentStudentName;
  final String currentStudentPhotoUrl;
  final String currentStudentPhone;
  final bool showRequestButton;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    final vehicleIcon = ride.vehicleType == VehicleType.car
        ? Icons.directions_car_rounded
        : Icons.two_wheeler_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: creator photo + info + vehicle icon
            Row(
              children: [
                _Avatar(
                  photoUrl: ride.creatorPhotoUrl,
                  name: ride.creatorName,
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.creatorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        '${ride.availableSeats} seat${ride.availableSeats != 1 ? 's' : ''} available',
                        style: const TextStyle(
                            color: Color(0xFF6B7280), fontSize: 12),
                      ),
                      // Phone number
                      if (ride.creatorPhone.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 12, color: Color(0xFF6B7280)),
                            const SizedBox(width: 4),
                            Text(
                              ride.creatorPhone,
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(vehicleIcon, color: _teal, size: 28),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Route info
            _RouteRow(
              fromIcon: Icons.location_on_rounded,
              toIcon: Icons.flag_rounded,
              source: ride.source,
              destination: ride.destination,
            ),
            const SizedBox(height: 10),

            // Date & time
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(ride.rideDateTime),
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  _formatTime(ride.rideDateTime),
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 13),
                ),
              ],
            ),

            if (ride.additionalDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ride.additionalDetails,
                style: const TextStyle(
                    color: Color(0xFF6B7280), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (showRequestButton) ...[
              const SizedBox(height: 14),
              _RequestButton(
                ride: ride,
                service: service,
                currentStudentId: currentStudentId,
                currentStudentName: currentStudentName,
                currentStudentPhotoUrl: currentStudentPhotoUrl,
                currentStudentPhone: currentStudentPhone,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request button — streams own request status in real time
// ─────────────────────────────────────────────────────────────────────────────

class _RequestButton extends StatefulWidget {
  const _RequestButton({
    required this.ride,
    required this.service,
    required this.currentStudentId,
    required this.currentStudentName,
    required this.currentStudentPhotoUrl,
    required this.currentStudentPhone,
  });

  final RideOffer ride;
  final RideSharingService service;
  final String currentStudentId;
  final String currentStudentName;
  final String currentStudentPhotoUrl;
  final String currentStudentPhone;

  @override
  State<_RequestButton> createState() => _RequestButtonState();
}

class _RequestButtonState extends State<_RequestButton> {
  static const _teal = Color(0xFF2AADC4);
  bool _loading = false;

  Future<void> _sendRequest() async {
    setState(() => _loading = true);
    final error = await widget.service.requestToJoin(
      rideId: widget.ride.id ?? '',
      requesterId: widget.currentStudentId,
      requesterName: widget.currentStudentName,
      requesterPhotoUrl: widget.currentStudentPhotoUrl,
      requesterPhone: widget.currentStudentPhone,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Request sent! Awaiting approval.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stream my request for this ride to show real-time status
    return StreamBuilder<List<RideRequest>>(
      stream: widget.service.streamMyRequests(
          requesterId: widget.currentStudentId),
      builder: (context, snap) {
        final myRequests = snap.data ?? [];
        final myRequest = myRequests.cast<RideRequest?>().firstWhere(
              (r) => r?.rideId == widget.ride.id,
              orElse: () => null,
            );

        if (myRequest != null) {
          // Show current status chip
          return _StatusChip(status: myRequest.status);
        }

        // "Request to Join" button
        final canRequest =
            widget.ride.isActive && widget.ride.availableSeats > 0;

        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: (canRequest && !_loading) ? _sendRequest : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(canRequest
                    ? 'Request to Join'
                    : 'No Seats Available'),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip (for Find a Ride tab request button)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final RideRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      RideRequestStatus.pending => ('Pending', const Color(0xFFFFF3CD), const Color(0xFF856404)),
      RideRequestStatus.approved => ('Approved ✓', const Color(0xFFD4EDDA), const Color(0xFF155724)),
      RideRequestStatus.rejected => ('Rejected', const Color(0xFFF8D7DA), const Color(0xFF721C24)),
      RideRequestStatus.rideCancelled => ('⚠️ Ride Cancelled', const Color(0xFFFFE5E5), const Color(0xFF9B1C1C)),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Requests group (for a specific ride in Requests tab — incoming view)
// ─────────────────────────────────────────────────────────────────────────────

class _RideRequestGroup extends StatelessWidget {
  const _RideRequestGroup({
    required this.ride,
    required this.requests,
    required this.service,
  });

  final RideOffer ride;
  final List<RideRequest> requests;
  final RideSharingService service;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride header
            Row(
              children: [
                const Icon(Icons.directions_car_rounded, color: _teal, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ride.source} → ${ride.destination}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0EFF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${requests.length} request${requests.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Text(
              '${_formatDate(ride.rideDateTime)} at ${_formatTime(ride.rideDateTime)} · ${ride.availableSeats} seats left',
              style:
                  const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Requests list
            ...requests.map((req) => _RequestRow(
                  request: req,
                  service: service,
                  rideId: ride.id ?? '',
                  rideIsActive: ride.status == RideStatus.active,
                  availableSeats: ride.availableSeats,
                )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual request row with Accept/Reject buttons — with profile photo + phone
// ─────────────────────────────────────────────────────────────────────────────

class _RequestRow extends StatefulWidget {
  const _RequestRow({
    required this.request,
    required this.service,
    required this.rideId,
    required this.rideIsActive,
    required this.availableSeats,
  });

  final RideRequest request;
  final RideSharingService service;
  final String rideId;
  final bool rideIsActive;
  final int availableSeats;

  @override
  State<_RequestRow> createState() => _RequestRowState();
}

class _RequestRowState extends State<_RequestRow> {
  bool _processing = false;

  Future<void> _approve() async {
    setState(() => _processing = true);
    try {
      await widget.service.approveRequest(
        requestId: widget.request.id ?? '',
        rideId: widget.rideId,
        requesterId: widget.request.requesterId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to approve: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _processing = true);
    try {
      await widget.service.rejectRequest(widget.request.id ?? '');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to reject: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isPending = req.status == RideRequestStatus.pending;
    final canAction = isPending &&
        widget.rideIsActive &&
        widget.availableSeats > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(
                photoUrl: req.requesterPhotoUrl,
                name: req.requesterName,
                radius: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.requesterName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    // Phone number
                    if (req.requesterPhone.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 11, color: Color(0xFF6B7280)),
                          const SizedBox(width: 3),
                          Text(
                            req.requesterPhone,
                            style: const TextStyle(
                                color: Color(0xFF6B7280), fontSize: 11),
                          ),
                        ],
                      ),
                    if (!isPending)
                      Text(
                        req.statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(req.status),
                        ),
                      ),
                  ],
                ),
              ),
              if (_processing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (canAction) ...[
                _ActionButton(
                  label: 'Accept',
                  color: const Color(0xFF2AADC4),
                  onTap: _approve,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Reject',
                  color: Colors.redAccent,
                  onTap: _reject,
                ),
              ] else
                _StatusBadge(status: req.status),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(RideRequestStatus s) {
    return switch (s) {
      RideRequestStatus.approved => const Color(0xFF155724),
      RideRequestStatus.rejected => const Color(0xFF721C24),
      RideRequestStatus.rideCancelled => const Color(0xFF6B7280),
      _ => const Color(0xFF856404),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Ride Card (owner view)
// ─────────────────────────────────────────────────────────────────────────────

class _MyRideCard extends StatelessWidget {
  const _MyRideCard({required this.ride, required this.service});

  final RideOffer ride;
  final RideSharingService service;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    final filled = ride.totalSeats - ride.availableSeats;
    final vehicleIcon = ride.vehicleType == VehicleType.car
        ? Icons.directions_car_rounded
        : Icons.two_wheeler_rounded;

    final statusColor = ride.status == RideStatus.active
        ? const Color(0xFF155724)
        : Colors.redAccent;
    final statusLabel = ride.status == RideStatus.cancelled
        ? 'Cancelled'
        : ride.isExpired
            ? 'Expired'
            : 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(vehicleIcon, color: _teal, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${ride.source} → ${ride.destination}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date & time
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 5),
                Text(_formatDate(ride.rideDateTime),
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_rounded,
                    size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 5),
                Text(_formatTime(ride.rideDateTime),
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            // Seat stats
            Row(
              children: [
                _SeatStat(
                    label: 'Total', value: '${ride.totalSeats}', color: _teal),
                const SizedBox(width: 16),
                _SeatStat(
                    label: 'Available',
                    value: '${ride.availableSeats}',
                    color: const Color(0xFF155724)),
                const SizedBox(width: 16),
                _SeatStat(
                    label: 'Filled',
                    value: '$filled',
                    color: Colors.orange.shade700),
              ],
            ),

            // Participants
            if (ride.participantIds.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Joined: ${ride.participantIds.length} passenger${ride.participantIds.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: Color(0xFF2AADC4),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],

            if (ride.additionalDetails.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(ride.additionalDetails,
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],

            // Cancel/Delete button (only for active rides)
            if (ride.status == RideStatus.active && !ride.isExpired) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 18),
                  label: const Text('Delete Ride',
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ride?'),
        content: const Text(
            'This will cancel the ride and notify all passengers. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await service.cancelRide(ride.id ?? '');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride deleted and passengers notified.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Avatar widget (handles NetworkImage with fallback initial)
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photoUrl,
    required this.name,
    required this.radius,
  });

  final String photoUrl;
  final String name;
  final double radius;

  static const _teal = Color(0xFF2AADC4);

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFD0EFF4),
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFD0EFF4),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _teal,
            fontSize: radius * 0.85),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.fromIcon,
    required this.toIcon,
    required this.source,
    required this.destination,
  });

  final IconData fromIcon;
  final IconData toIcon;
  final String source;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Icon(fromIcon, size: 16, color: const Color(0xFF2AADC4)),
            Container(
                width: 1, height: 14, color: const Color(0xFFD0EFF4)),
            Icon(toIcon, size: 16, color: Colors.redAccent),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(source,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text(destination,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeatStat extends StatelessWidget {
  const _SeatStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final RideRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RideRequestStatus.approved => ('Approved', const Color(0xFF155724)),
      RideRequestStatus.rejected => ('Rejected', Colors.redAccent),
      RideRequestStatus.rideCancelled => ('Ride Cancelled', const Color(0xFF6B7280)),
      _ => ('Pending', const Color(0xFF856404)),
    };
    return Text(label,
        style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700));
  }
}

class _SectionEmptyHint extends StatelessWidget {
  const _SectionEmptyHint({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFD0EFF4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Color(0xFF2AADC4)),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
