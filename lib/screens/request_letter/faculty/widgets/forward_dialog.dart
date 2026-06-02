
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/faculty_model.dart';
import '../providers/availability_provider.dart';
import '../providers/request_provider.dart';

class ForwardDialog extends StatefulWidget {
  final String requestId;
  final Faculty currentFaculty;
  final VoidCallback onForwarded;

  const ForwardDialog({
    super.key,
    required this.requestId,
    required this.currentFaculty,
    required this.onForwarded,
  });

  @override
  State<ForwardDialog> createState() => _ForwardDialogState();
}

class _ForwardDialogState extends State<ForwardDialog> {
  String _searchQuery = '';
  List<Faculty> _filteredFaculty = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailabilityProvider>().fetchAllFaculty();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final availabilityProvider = context.watch<AvailabilityProvider>();
    final allFaculty = availabilityProvider.allFaculty.where((f) {
      // Logic for forwarding:
      // Hide self, hide faculty on leave
      return f.facultyId != widget.currentFaculty.facultyId && f.availabilityStatus == 'Present';
    }).toList();

    _filteredFaculty = allFaculty.where((f) {
      final name = f.name.toLowerCase();
      final id = f.facultyId.toLowerCase();
      final des = f.designation.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || id.contains(query) || des.contains(query);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forward Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name, ID or designation',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF98A2B3)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBlue, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: availabilityProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFaculty.isEmpty
                      ? const Center(child: Text('No available faculty found.'))
                      : ListView.separated(
                          itemCount: _filteredFaculty.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final faculty = _filteredFaculty[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: primaryBlue.withValues(alpha: 0.1),
                                child: Text(faculty.name[0], style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(faculty.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(faculty.designation, style: const TextStyle(fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.send_rounded, color: primaryBlue),
                                onPressed: () => _forwardTo(faculty),
                              ),
                              onTap: () => _forwardTo(faculty),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF667085))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _forwardTo(Faculty target) async {
    final provider = context.read<RequestProvider>();
    final nextStatus = 'Forwarded to ${target.role.toString().split('.').last.toUpperCase()}';
    
    await provider.forward(
      widget.requestId,
      widget.currentFaculty.facultyId,
      widget.currentFaculty.name,
      target.facultyId,
      target.name,
      nextStatus,
    );

    widget.onForwarded();
    if (mounted) Navigator.pop(context);
  }
}
