
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/request_model.dart';
import '../models/faculty_model.dart';
import '../models/history_model.dart';
import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';
import '../widgets/forward_dialog.dart';

class RequestDetailsScreen extends StatefulWidget {
  final RequestLetter request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late Future<List<RequestHistory>> _timelineFuture;
  late String _currentStatus;
  late String _rejectionReason;
  bool _actionCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status;
    _rejectionReason = widget.request.rejectionReason ?? '';
    _timelineFuture = context.read<RequestProvider>().getTimeline(widget.request.requestId);
  }

  void _refreshTimeline() {
    setState(() {
      _timelineFuture = context.read<RequestProvider>().getTimeline(widget.request.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final faculty = context.read<AuthProvider>().currentFaculty;
    if (faculty == null) return const SizedBox.shrink();
    final isPending = (_currentStatus == 'Pending' || _currentStatus.contains('Forwarded')) && !_actionCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Request Details', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(primaryBlue),
            _buildStudentInfo(),
            _buildRequestContent(),
            _buildTimeline(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: isPending ? _buildActionButtons(context, faculty, primaryBlue) : null,
    );
  }

  Widget _buildStatusHeader(Color color) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Status: $_currentStatus',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (_currentStatus == 'Rejected' && _rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Reason: $_rejectionReason',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoColumn('Name', widget.request.studentName),
              const Spacer(),
              _buildInfoColumn('Student ID', widget.request.studentId),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoColumn('Submission Date', DateFormat('MMMM dd, yyyy').format(widget.request.submissionDate)),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
      ],
    );
  }

  Widget _buildRequestContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request Content', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
          const SizedBox(height: 12),
          Text(
            widget.request.requestContent,
            style: const TextStyle(fontSize: 15, color: Color(0xFF344054), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Approval Workflow', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
          const SizedBox(height: 20),
          FutureBuilder<List<RequestHistory>>(
            future: _timelineFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final history = snapshot.data ?? [];
              if (history.isEmpty) return const Text('No history available yet.');

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final h = history[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.check_circle, size: 20, color: Colors.blue),
                          if (index != history.length - 1) Container(width: 2, height: 40, color: Colors.blue.withValues(alpha: 0.3)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.action == 'Forwarded' 
                                  ? 'Forwarded by ${h.fromFacultyName} to ${h.toFacultyName}'
                                  : '${h.action} by ${h.fromFacultyName}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              DateFormat('MMM dd, hh:mm a').format(h.actionDateTime),
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Faculty faculty, Color primary) {
    final provider = context.read<RequestProvider>();
    final canForward = faculty.role != FacultyRole.principal;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _openRejectDialog(context, faculty, provider),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          if (canForward) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _openForwardDialog(context, faculty),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Forward', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await provider.approve(widget.request.requestId, faculty.facultyId, faculty.name);
                if (!mounted || !context.mounted) return;
                setState(() {
                  _currentStatus = 'Approved';
                  _actionCompleted = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Approved')));
                _refreshTimeline();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _openForwardDialog(BuildContext context, Faculty currentFaculty) {
    showDialog(
      context: context,
      builder: (context) => ForwardDialog(
        requestId: widget.request.requestId,
        currentFaculty: currentFaculty,
        onForwarded: () {
          if (mounted) {
            setState(() {
              _currentStatus = 'Forwarded by ${currentFaculty.name}';
              _actionCompleted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Forwarded')));
            _refreshTimeline();
          }
        },
      ),
    );
  }

  void _openRejectDialog(BuildContext context, Faculty faculty, RequestProvider provider) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a reason.')));
                  return;
                }
                Navigator.pop(context); // close dialog
                await provider.reject(widget.request.requestId, faculty.facultyId, faculty.name, reason);
                if (!mounted || !context.mounted) return;
                setState(() {
                  _currentStatus = 'Rejected';
                  _rejectionReason = reason;
                  _actionCompleted = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Rejected')));
                _refreshTimeline();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
