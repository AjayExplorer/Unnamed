import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/bus_tracking_provider.dart';
import '../models/bus_model.dart';
import '../models/tracking_model.dart';
import '../widgets/animated_bus_map.dart';
import '../widgets/timeline_widget.dart';
import '../services/routing_service.dart';

class StudentLiveTrackingScreen extends StatefulWidget {
  const StudentLiveTrackingScreen({super.key});

  @override
  State<StudentLiveTrackingScreen> createState() => _StudentLiveTrackingScreenState();
}

class _StudentLiveTrackingScreenState extends State<StudentLiveTrackingScreen> {
  LatLng? _studentLocation;
  String _busId = '';
  double _sheetExtent = 0.45;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_busId.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _busId = args;
        // Listen to this bus tracking state
        final provider = context.read<BusTrackingProvider>();
        provider.listenToBusLive(_busId);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getStudentCurrentLocation();
  }

  @override
  void dispose() {
    // stop listening to live tracking state
    context.read<BusTrackingProvider>().stopListeningToBusLive();
    super.dispose();
  }

  Future<void> _getStudentCurrentLocation() async {
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _studentLocation = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      debugPrint('Error getting student location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    final provider = context.watch<BusTrackingProvider>();
    final tracking = provider.activeTrackingState;

    // Find static bus details from list
    Bus? bus;
    try {
      bus = provider.buses.firstWhere((b) => b.busId == _busId);
    } catch (e) {
      // fallback
    }

    if (bus == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Tracking')),
        body: const Center(child: Text('Bus details not found.')),
      );
    }

    // Calculations for Student Distance and ETA
    double? distanceToStudent;
    String? etaToStudent;

    if (tracking != null && _studentLocation != null) {
      distanceToStudent = RoutingService.calculateDistance(
        tracking.latitude,
        tracking.longitude,
        _studentLocation!.latitude,
        _studentLocation!.longitude,
      );
      etaToStudent = RoutingService.calculateLocalETA(distanceToStudent);
    }

    final bool isLive = tracking != null && tracking.trackingActive;

    // Calculate map height depending on sheet extent
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;
    final mapHeight = availableHeight * (1.0 - _sheetExtent);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text('${bus.busNumber} Live Track', style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Live Map View that resizes dynamically based on drag
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: tracking != null
                ? AnimatedBusMap(
                    busLocation: LatLng(tracking.latitude, tracking.longitude),
                    studentLocation: _studentLocation,
                    sourceLocation: tracking.direction == 'from_college'
                        ? LatLng(bus.route.destination.latitude, bus.route.destination.longitude)
                        : LatLng(bus.route.source.latitude, bus.route.source.longitude),
                    destinationLocation: tracking.direction == 'from_college'
                        ? LatLng(bus.route.source.latitude, bus.route.source.longitude)
                        : LatLng(bus.route.destination.latitude, bus.route.destination.longitude),
                    stopLocations: tracking.direction == 'from_college'
                        ? bus.route.stops.reversed.map((s) => LatLng(s.latitude, s.longitude)).toList()
                        : bus.route.stops.map((s) => LatLng(s.latitude, s.longitude)).toList(),
                    trackingActive: isLive,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text('Initializing tracking session...', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
          ),
          
          // 2. Draggable Bottom Tile Card (showing location details, bus stops)
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                _sheetExtent = notification.extent;
              });
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.35,
              maxChildSize: 0.85,
              snap: true,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          // Draggable drag handle representation
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: 50,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E7EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const TabBar(
                            labelColor: primaryBlue,
                            indicatorColor: primaryBlue,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            tabs: [
                              Tab(text: 'Bus Information'),
                              Tab(text: 'Route Timeline'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Tab 1: Bus Info Card
                                _buildInfoTab(bus!, tracking, isLive, distanceToStudent, etaToStudent, scrollController),
                                // Tab 2: Route Timeline
                                _buildTimelineTab(tracking, bus, scrollController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(Bus bus, BusTrackingState? tracking, bool isLive, double? distanceToStudent, String? etaToStudent, ScrollController scrollController) {
    const successGreen = Color(0xFF10B981);
    const errorRed = Color(0xFFEF4444);

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.busName ?? 'Green Valley Route',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lic. Plate: ${bus.numberPlate}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF667085), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isLive ? successGreen.withValues(alpha: 0.1) : errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLive ? 'LIVE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLive ? successGreen : errorRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          // Local student calculation card
          if (distanceToStudent != null && etaToStudent != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8EFE9), Color(0xFFD8ECE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB4CAB8).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: Color(0xFF31A25C), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Arrival to Your Location',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$etaToStudent away (${distanceToStudent.toStringAsFixed(1)} km)',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Grid metadata
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildMetricCard('Driver', bus.driverName),
              _buildMetricCard('Next Stop', tracking != null && tracking.nextStop.isNotEmpty ? tracking.nextStop : '--'),
              _buildMetricCard('Speed', tracking != null ? '${tracking.currentSpeed.toStringAsFixed(1)} km/h' : '0.0 km/h'),
              _buildMetricCard('ETA to Next Stop', tracking != null ? tracking.eta : '--'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(BusTrackingState? tracking, Bus bus, ScrollController scrollController) {
    if (tracking == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20.0),
      child: RouteTimelineWidget(
        stops: tracking.stopsStatus,
      ),
    );
  }
}
