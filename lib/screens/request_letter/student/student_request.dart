import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRequestPage extends StatefulWidget {
  const StudentRequestPage({super.key});

  @override
  State<StudentRequestPage> createState() => _StudentRequestPageState();
}

class _StudentRequestPageState extends State<StudentRequestPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _requestController = TextEditingController();
  
  String _searchQuery = "";
  String? _selectedFacultyId;
  String? _selectedFacultyName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    _requestController.dispose();
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
    if (_requestController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your request text details.')),
      );
      return;
    }

    /*setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'facultyId': _selectedFacultyId,
        'facultyName': _selectedFacultyName,
        'requestText': _requestController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
        // Note: Replace with actual logged-in user context if dynamic state is setup
        'studentName': 'Current Student', 
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
  }*/

    // Mock submission flow for local testing without Firestore
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully! (Mock)')),
      );
      Navigator.of(context).pop();
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

                        /* =============================================================
                        BACKEND TODO: UNCOMMENT THIS BLOCK ONCE FIREBASE IS SET UP
                        =============================================================
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('faculties').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error loading faculty list.');
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final docs = snapshot.data!.docs.where((doc) {
                              final name = (doc['name'] ?? '').toString().toLowerCase();
                              final dept = (doc['department'] ?? '').toString().toLowerCase();
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
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final String id = doc.id;
                                final String name = doc['name'] ?? 'Unknown Name';
                                final String dept = doc['department'] ?? 'General Department';
                                final String photoUrl = doc.data().toString().contains('photoUrl') ? doc['photoUrl'] : '';

                                final bool isSelected = _selectedFacultyId == id;

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
                                            Text(
                                              name,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF101828)),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              dept,
                                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: textGrey),
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
                        */

                        // --- TEMPORARY MOCK DATA FOR LOCAL TESTING ---
                        // REMOVE OR COMMENT THIS OUT WHEN THE STREAMBUILDER ABOVE IS ACTIVE
                        () {
                          final List<Map<String, String>> mockFaculties = [
                            {'id': '1', 'name': 'Dr. A. Sharma', 'department': 'Department of Computer Science'},
                            {'id': '2', 'name': 'Prof. B. Rai', 'department': 'Department of Electronics'},
                            {'id': '3', 'name': 'Ms. C. Gomez', 'department': 'Department of Civil'},
                          ];

                          final filteredDocs = mockFaculties.where((faculty) {
                            final name = faculty['name']!.toLowerCase();
                            final dept = faculty['department']!.toLowerCase();
                            return name.contains(_searchQuery) || dept.contains(_searchQuery);
                          }).toList();

                          if (filteredDocs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('No matching faculty members found.', style: TextStyle(color: textGrey)),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredDocs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final faculty = filteredDocs[index];
                              final String id = faculty['id']!;
                              final String name = faculty['name']!;
                              final String dept = faculty['department']!;
                              final bool isSelected = _selectedFacultyId == id;

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE4E7EC)),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Color(0xFFD8ECE0),
                                      child: Icon(Icons.person, color: Color(0xFF344054)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF101828)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dept,
                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: textGrey),
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
                        }(),
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