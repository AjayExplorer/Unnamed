import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_tracking_provider.dart';
import '../models/bus_model.dart';

class StudentBusHomeScreen extends StatefulWidget {
  const StudentBusHomeScreen({super.key});

  @override
  State<StudentBusHomeScreen> createState() => _StudentBusHomeScreenState();
}

class _StudentBusHomeScreenState extends State<StudentBusHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BusTrackingProvider>();
      provider.loadBuses();
      provider.startAllTrackingStream(); // start listening to real-time states of all buses
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusTrackingProvider>();
    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Bus Selection', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF344054)),
          onPressed: () {
            provider.stopAllTrackingStream();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.searchBuses(val),
              decoration: InputDecoration(
                hintText: 'Search by Bus, Route, or Stop...',
                hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF667085)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF667085)),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchBuses('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Bus list
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.matchingBuses.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: provider.matchingBuses.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bus = provider.matchingBuses[index];
                          // Find live status for this bus in allTrackingStates
                          final tracking = provider.allTrackingStates.where((t) => t.busId == bus.busId).toList();
                          final bool isActive = tracking.isNotEmpty && tracking.first.trackingActive;
                          
                          return _buildBusCard(bus, isActive);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bus_filled_outlined,
                size: 72,
                color: Color(0xFF98A2B3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No matching buses found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search filters or check with the campus administration for route listings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusCard(Bus bus, bool isActive) {
    const successGreen = Color(0xFF10B981);
    const errorRed = Color(0xFFEF4444);

    final statusColor = isActive ? successGreen : errorRed;
    final statusText = isActive ? 'Active • Live' : 'Offline';

    return Hero(
      tag: 'bus_card_${bus.busId}',
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.04),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to live tracking screen
            Navigator.of(context).pushNamed(
              '/student_live_tracking',
              arguments: bus.busId,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                // Bus Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bus.busNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101828),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bus.busName ?? 'Campus Bus Route',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Plate: ${bus.numberPlate}  •  Stops: ${bus.route.stops.length + 2}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
