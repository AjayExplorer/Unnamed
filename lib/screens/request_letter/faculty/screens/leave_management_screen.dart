
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LeaveManagementScreen extends StatelessWidget {
  const LeaveManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Leave Management', style: TextStyle(fontWeight: FontWeight.w700, color: primaryBlue)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlue),
      ),
      body: const MyAvailabilityTab(),
    );
  }
}

class MyAvailabilityTab extends StatelessWidget {
  const MyAvailabilityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final faculty = authProvider.currentFaculty;
    if (faculty == null) return const SizedBox();

    const primaryBlue = Color(0xFF174EA6);
    final isOnLeave = faculty.availabilityStatus == 'On Leave';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 40, color: primaryBlue),
                ),
                const SizedBox(height: 16),
                Text(faculty.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(faculty.designation, style: const TextStyle(color: Color(0xFF667085))),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isOnLeave ? Colors.red : Colors.green).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        faculty.availabilityStatus,
                        style: TextStyle(
                          color: isOnLeave ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final newStatus = isOnLeave ? 'Present' : 'On Leave';
                      authProvider.updateMyAvailability(newStatus);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOnLeave ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isOnLeave ? 'Mark as Present' : 'Mark as On Leave',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
