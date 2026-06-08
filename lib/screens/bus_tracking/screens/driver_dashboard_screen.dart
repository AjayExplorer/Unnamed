import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/bus_tracking_provider.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  String? _selectedDirection;

  @override
  void initState() {
    super.initState();
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stop Tracking?'),
          content: const Text(
            'Are you sure you want to stop location broadcasting? The bus status will be marked as inactive.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BusTrackingProvider>().stopTracking();
                setState(() {
                  _selectedDirection = null;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDA29B),
              ),
              child: const Text(
                'Stop Broadcasting',
                style: TextStyle(color: Color(0xFFB01212)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusTrackingProvider>();
    final driver = provider.currentDriver;
    final bus = provider.assignedBus;
    final tracking = provider.activeTrackingState;

    if (provider.isTracking && tracking != null && _selectedDirection == null) {
      _selectedDirection = tracking.direction;
    }

    const primaryBlue = Color(0xFF174EA6);
    const secondaryTeal = Color(0xFF0F766E);
    const successGreen = Color(0xFF10B981);
    const warningAmber = Color(0xFFF59E0B);
    const errorRed = Color(0xFFEF4444);

    Color gpsColor;
    if (provider.gpsStatus == 'Active') {
      gpsColor = successGreen;
    } else if (provider.gpsStatus == 'Waiting') {
      gpsColor = warningAmber;
    } else {
      gpsColor = errorRed;
    }

    final formattedTime = provider.lastUpdateTime != null
        ? DateFormat('hh:mm:ss a').format(provider.lastUpdateTime!)
        : 'Never';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Driver Portal',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/driver_profile');
            },
            tooltip: 'Driver Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.stopTracking();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: driver == null
          ? const Center(child: CircularProgressIndicator())
          : bus == null
          ? _buildNoBusAssignedView(context, driver, provider)
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Driver Header Card
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/driver_profile'),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.08),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFFE4E7EC),
                              foregroundImage:
                                  (driver.profilePhoto != null &&
                                      driver.profilePhoto!.isNotEmpty)
                                  ? NetworkImage(driver.profilePhoto!)
                                  : null,
                              child: const Icon(
                                Icons.person,
                                size: 36,
                                color: Color(0xFF98A2B3),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF101828),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bus.busName ?? 'Assigned Route',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTeal,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          bus.busNumber.isEmpty
                                              ? 'No Bus'
                                              : bus.busNumber,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        bus.numberPlate.isEmpty
                                            ? '--'
                                            : bus.numberPlate,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF667085),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF98A2B3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. GPS Status Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: gpsColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GPS BROADCAST: ${provider.gpsStatus.toUpperCase()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: gpsColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.isTracking
                                      ? 'Accuracy: ${provider.gpsAccuracy.toStringAsFixed(1)} meters'
                                      : 'Broadcasting is stopped.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Last: $formattedTime',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2.5 Route Direction Selector
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Trip Direction',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: provider.isTracking
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedDirection = 'to_college';
                                          });
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedDirection == 'to_college'
                                          ? primaryBlue.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedDirection == 'to_college'
                                            ? primaryBlue
                                            : const Color(0xFFD0D5DD),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.school_outlined,
                                            color: _selectedDirection == 'to_college'
                                                ? primaryBlue
                                                : const Color(0xFF667085),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'To College',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: _selectedDirection == 'to_college'
                                                  ? primaryBlue
                                                  : const Color(0xFF344054),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: provider.isTracking
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedDirection = 'from_college';
                                          });
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedDirection == 'from_college'
                                          ? secondaryTeal.withOpacity(0.1)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _selectedDirection == 'from_college'
                                            ? secondaryTeal
                                            : const Color(0xFFD0D5DD),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.home_outlined,
                                            color: _selectedDirection == 'from_college'
                                                ? secondaryTeal
                                                : const Color(0xFF667085),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'From College',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: _selectedDirection == 'from_college'
                                                  ? secondaryTeal
                                                  : const Color(0xFF344054),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Main Controls
                  // Start Tracking Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: (provider.isTracking || _selectedDirection == null)
                          ? null
                          : () => provider.startTracking(direction: _selectedDirection!),
                      icon: const Icon(Icons.play_circle_fill, size: 28),
                      label: const Text(
                        'START BROADCASTING',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryTeal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stop Tracking Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton.icon(
                      onPressed: !provider.isTracking
                          ? null
                          : _showStopConfirmation,
                      icon: const Icon(Icons.stop_circle, size: 28),
                      label: const Text(
                        'STOP BROADCASTING',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: provider.isTracking
                              ? errorRed
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        foregroundColor: errorRed,
                        disabledForegroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 4. Live Info Section
                  const Text(
                    'Real-Time Broadcast Data',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildLiveRow(
                            'Coordinates',
                            tracking != null
                                ? '${tracking.latitude.toStringAsFixed(5)}, ${tracking.longitude.toStringAsFixed(5)}'
                                : 'None',
                          ),
                          const Divider(),
                          _buildLiveRow(
                            'Current Speed',
                            tracking != null
                                ? '${tracking.currentSpeed.toStringAsFixed(1)} km/h'
                                : '0.0 km/h',
                          ),
                          const Divider(),
                          _buildLiveRow(
                            'Last Reached Stop',
                            tracking != null && tracking.currentStop.isNotEmpty
                                ? tracking.currentStop
                                : 'None',
                          ),
                          const Divider(),
                          _buildLiveRow(
                            'Upcoming Stop',
                            tracking != null && tracking.nextStop.isNotEmpty
                                ? tracking.nextStop
                                : 'None',
                          ),
                          const Divider(),
                          _buildLiveRow(
                            'Distance to Next Stop',
                            tracking != null
                                ? '${tracking.distanceToNextStop.toStringAsFixed(2)} km'
                                : '0.00 km',
                          ),
                          const Divider(),
                          _buildLiveRow(
                            'ETA to Next Stop',
                            tracking != null ? tracking.eta : '--',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLiveRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBusAssignedView(
    BuildContext context,
    dynamic driver,
    BusTrackingProvider provider,
  ) {
    const primaryBlue = Color(0xFF174EA6);
    const warningAmber = Color(0xFFF59E0B);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver info card (still shown)
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/driver_profile'),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.08),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFE4E7EC),
                      foregroundImage:
                          (driver.profilePhoto != null &&
                              driver.profilePhoto!.isNotEmpty)
                          ? NetworkImage(driver.profilePhoto!)
                          : null,
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bus Driver',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // No Bus Assigned Warning Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  warningAmber.withOpacity(0.08),
                  warningAmber.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: warningAmber.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: warningAmber.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus_outlined,
                    size: 36,
                    color: warningAmber,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Bus Assigned',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have not been assigned a bus or route yet.\nPlease contact the administrator to get a bus and route assigned to your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF667085),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tracking features are disabled',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Disabled GPS Status Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 1,
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPS BROADCAST: DISABLED',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No bus assigned — broadcasting unavailable.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Disabled Start Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.play_circle_fill, size: 28),
              label: const Text(
                'START BROADCASTING',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.grey[600],
                disabledBackgroundColor: Colors.grey[200],
                disabledForegroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Disabled Stop Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.stop_circle, size: 28),
              label: const Text(
                'STOP BROADCASTING',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!, width: 2),
                foregroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Disabled Live Info
          Text(
            'Real-Time Broadcast Data',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 1,
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildDisabledLiveRow('Coordinates', 'N/A'),
                  Divider(color: Colors.grey[200]),
                  _buildDisabledLiveRow('Current Speed', 'N/A'),
                  Divider(color: Colors.grey[200]),
                  _buildDisabledLiveRow('Last Reached Stop', 'N/A'),
                  Divider(color: Colors.grey[200]),
                  _buildDisabledLiveRow('Upcoming Stop', 'N/A'),
                  Divider(color: Colors.grey[200]),
                  _buildDisabledLiveRow('Distance to Next Stop', 'N/A'),
                  Divider(color: Colors.grey[200]),
                  _buildDisabledLiveRow('ETA to Next Stop', 'N/A'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledLiveRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
