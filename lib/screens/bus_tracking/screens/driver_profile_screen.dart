import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_tracking_provider.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final driver = context.read<BusTrackingProvider>().currentDriver;
    if (driver != null) {
      _urlController.text = driver.profilePhoto ?? '';
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _updatePhotoUrl() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<BusTrackingProvider>();
    await provider.updateProfilePhoto(_urlController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture URL updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusTrackingProvider>();
    final driver = provider.currentDriver;
    final bus = provider.assignedBus;

    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: driver == null || bus == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Avatar Card
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFE4E7EC),
                          foregroundImage: (driver.profilePhoto != null && driver.profilePhoto!.isNotEmpty)
                              ? NetworkImage(driver.profilePhoto!)
                              : null,
                          child: const Icon(Icons.person, size: 54, color: Color(0xFF98A2B3)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Driver Account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Info Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildProfileRow(Icons.directions_bus_outlined, 'Assigned Bus', bus.busNumber.isEmpty ? 'No bus assigned' : bus.busNumber),
                          const Divider(height: 24),
                          _buildProfileRow(Icons.pin_outlined, 'Number Plate', bus.numberPlate.isEmpty ? '--' : bus.numberPlate),
                          const Divider(height: 24),
                          _buildProfileRow(Icons.route_outlined, 'Route Name', bus.busName ?? 'No route name'),
                          const Divider(height: 24),
                          _buildProfileRow(Icons.phone_outlined, 'Phone Number', driver.phone),
                          const Divider(height: 24),
                          _buildProfileRow(Icons.home_outlined, 'Home Address', driver.address ?? '--'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile URL edit card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Image Settings',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Set a custom profile picture by providing an image URL.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _urlController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Profile Image URL',
                                hintText: 'https://example.com/avatar.jpg',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.link),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return null;
                                if (!value.trim().startsWith('http://') && !value.trim().startsWith('https://')) {
                                  return 'Enter a valid URL starting with http:// or https://';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _updatePhotoUrl,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text('Update Profile Image', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF174EA6), size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
