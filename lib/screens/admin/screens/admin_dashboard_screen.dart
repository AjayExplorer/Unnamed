import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../request_letter/faculty/models/faculty_registration_request.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF174EA6)),
            onPressed: () {
              context.read<AdminProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(provider),
            const SizedBox(height: 20),
            const Text('Pending Faculty Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Expanded(child: _buildRequestList(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(AdminProvider provider) {
    const primaryBlue = Color(0xFF174EA6);
    return Row(
      children: [
        _buildMetricCard('Pending', provider.pendingRequests.length.toString(), primaryBlue),
        const SizedBox(width: 12),
        _buildMetricCard('Registered Faculty', provider.facultyCount.toString(), primaryBlue),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color primaryBlue) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF667085), fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: primaryBlue, fontSize: 28, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(AdminProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.pendingRequests.isEmpty) {
      return const Center(child: Text('No pending faculty registration requests.'));
    }

    return ListView.separated(
      itemCount: provider.pendingRequests.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = provider.pendingRequests[index];
        return _buildRequestCard(request, provider);
      },
    );
  }

  Widget _buildRequestCard(FacultyRegistrationRequest request, AdminProvider provider) {
    const primaryBlue = Color(0xFF174EA6);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              request.designation.isNotEmpty
                  ? '${request.designation} • ${request.role.toString().split('.').last}'
                  : request.role.toString().split('.').last,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text('Username: ${request.username}'),
            Text('Email: ${request.email}'),
            Text('Phone: ${request.phone}'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleReject(request, provider),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApprove(request, provider),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleApprove(FacultyRegistrationRequest request, AdminProvider provider) async {
    await provider.approveRequest(request);
    if (!mounted) return;
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty request approved.')));
    }
  }

  void _handleReject(FacultyRegistrationRequest request, AdminProvider provider) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Enter rejection reason'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Reject')),
          ],
        );
      },
    );

    if (result == true) {
      await provider.rejectRequest(request.requestId, reasonController.text.trim());
      if (!mounted) return;
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty request rejected.')));
      }
    }
  }
}
