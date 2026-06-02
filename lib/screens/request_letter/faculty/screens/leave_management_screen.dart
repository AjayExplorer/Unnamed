
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/availability_provider.dart';
import '../models/history_model.dart';

class LeaveManagementScreen extends StatelessWidget {
  const LeaveManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          title: const Text('Leave Management', style: TextStyle(fontWeight: FontWeight.w700, color: primaryBlue)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: primaryBlue,
            unselectedLabelColor: Color(0xFF667085),
            indicatorColor: primaryBlue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'My Availability'),
              Tab(text: 'Staff Management'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyAvailabilityTab(),
            StaffAvailabilityTab(),
          ],
        ),
      ),
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
          const SizedBox(height: 32),
          const Text('Availability History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FutureBuilder<List<AvailabilityHistory>>(
            future: context.read<AvailabilityProvider>().getHistory(faculty.facultyId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final history = snapshot.data ?? [];
              if (history.isEmpty) return const Text('No history found.', style: TextStyle(color: Colors.grey));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final h = history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          h.newStatus == 'Present' ? Icons.check_circle : Icons.remove_circle,
                          color: h.newStatus == 'Present' ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Changed to ${h.newStatus}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('Updated by: ${h.updatedByFacultyName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, HH:mm').format(h.updatedDateTime),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class StaffAvailabilityTab extends StatefulWidget {
  const StaffAvailabilityTab({super.key});

  @override
  State<StaffAvailabilityTab> createState() => _StaffAvailabilityTabState();
}

class _StaffAvailabilityTabState extends State<StaffAvailabilityTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailabilityProvider>().fetchAllFaculty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();
    final currentFaculty = context.read<AuthProvider>().currentFaculty!;
    
    final filtered = provider.allFaculty.where((f) {
      final query = _searchQuery.toLowerCase();
      return f.name.toLowerCase().contains(query) || f.facultyId.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search staff member...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final f = filtered[index];
                    final isOnLeave = f.availabilityStatus == 'On Leave';
                    
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (isOnLeave ? Colors.red : Colors.green).withValues(alpha: 0.1),
                              child: Text((f.name.isNotEmpty ? f.name[0] : '?'), style: TextStyle(color: isOnLeave ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(f.designation, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${f.availabilityStatus}',
                                    style: TextStyle(
                                      color: isOnLeave ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: !isOnLeave,
                              activeThumbColor: Colors.green,
                              inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                              inactiveThumbColor: Colors.red,
                              onChanged: (val) {
                                provider.updateStaffStatus(
                                  f.facultyId,
                                  val ? 'Present' : 'On Leave',
                                  currentFaculty.facultyId,
                                  currentFaculty.name,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
