import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';

class StudentRequestPage extends StatefulWidget {
  const StudentRequestPage({super.key});

  @override
  State<StudentRequestPage> createState() => _StudentRequestPageState();
}

class _StudentRequestPageState extends State<StudentRequestPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _requestController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  
  String _searchQuery = "";
  String? _selectedFacultyId;
  String? _selectedFacultyName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    _requestController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  // Submits the request data structure directly to Firestore
  void _sendRequest() async {
    if (_selectedFacultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a faculty member first.')),
      );
      return;
    }
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a subject for your request.')),
      );
      return;
    }
    if (_requestController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your request text details.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentStudent = Provider.of<StudentProvider>(context, listen: false).currentStudent;
      final studentId = currentStudent?.id ?? 'Unknown_ID';
      final studentName = currentStudent?.fullName ?? 'Unknown Student';

      await FirebaseFirestore.instance.collection('requests').add({
        'recipientFacultyId': _selectedFacultyId,
        'currentHandlerId': _selectedFacultyId,
        'currentHandlerName': _selectedFacultyName,
        'subject': _subjectController.text.trim(),
        'requestContent': _requestController.text.trim(),
        'submissionDate': DateTime.now().toIso8601String(),
        'status': 'Pending',
        'studentId': studentId,
        'studentName': studentName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exact color matching constants from teammate UI setup
    const primaryBlue = Color(0xFF174EA6); 
    const textGrey = Color(0xFF667085); //[span_15](start_span)//[span_15](end_span)

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF174EA6), Color(0xFF1E56B3), Color(0xFFF7F9FC)], //[span_16](end_span)
            stops: [0.0, 0.35, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'New Request Letter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Teammate Style capsule-styled Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Faculty Members',
                    prefixIcon: const Icon(Icons.search, color: textGrey),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F4),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 3. Rounded Bottom White Panel Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Dynamic Firebase Stream Builder for Real-time List Mapping
                        const Text(
                          'Registered Teachers',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 12),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('faculty').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error loading faculty list.');
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final docs = snapshot.data!.docs.where((doc) {
                              final name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                              final dept = (doc.data() as Map<String, dynamic>)['department']?.toString().toLowerCase() ?? '';
                              return name.contains(_searchQuery) || dept.contains(_searchQuery);
                            }).toList();

                            if (docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('No matching faculty members found.', style: TextStyle(color: textGrey)),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final String id = doc.id;
                                final data = doc.data() as Map<String, dynamic>;
                                final String name = data['name'] ?? 'Unknown Name';
                                final String dept = data['department'] ?? 'General Department';
                                final String designation = data['designation'] ?? 'Faculty';
                                final String availabilityStatus = data['availabilityStatus'] ?? 'Available';
                                final String photoUrl = data['profilePhoto'] ?? data['imageUrl'] ?? '';
                                
                                // Determine status color based on availability
                                final Color statusColor = availabilityStatus.toLowerCase() == 'on leave' 
                                  ? const Color(0xFFDC2626)  // Red for on leave
                                  : const Color(0xFF059669); // Green for available

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE4E7EC)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(0xFFD8ECE0),
                                        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                                        child: photoUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF344054)) : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF101828)),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    availabilityStatus,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 11,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    designation,
                                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: textGrey),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '• $dept',
                                                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11, color: Color(0xFF98A2B3)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Radio<String>(
                                        value: id,
                                        groupValue: _selectedFacultyId,
                                        activeColor: primaryBlue,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedFacultyId = value;
                                            _selectedFacultyName = name;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                    
                        const SizedBox(height: 24),

                        // 4. Request Description Frame Section
                        const Text(
                          'Write your Request...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828), //[span_22](end_span)
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        TextField(
                          controller: _subjectController,
                          decoration: InputDecoration(
                            hintText: 'Subject',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: primaryBlue, width: 1.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Large multiline input message input container matching teammate border standards
                        TextField(
                          controller: _requestController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Write your request details here...',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB), //[span_23](end_span)
                            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14), //[span_24](end_span)
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), //[span_25](end_span)
                              borderSide: const BorderSide(color: Color(0xFFE4E7EC)), //[span_26](end_span)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), //[span_27](end_span)
                              borderSide: const BorderSide(color: primaryBlue, width: 1.4), //[span_28](end_span)
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 5. Submit Execution Button Form Frame
                        SizedBox(
                          width: double.infinity,
                          height: 50, //[span_29](end_span)
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _sendRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue, //[span_30](end_span)
                              foregroundColor: Colors.white, //[span_31](end_span)
                              elevation: 0, //[span_32](end_span)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999), //[span_33](end_span)
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Send Request',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700), //[span_34](end_span)
                                  ),
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
      ),
    );
  }
}