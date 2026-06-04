import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../providers/student_provider.dart';
import 'utils/file_download_helper.dart';

class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({super.key});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);
    final currentStudent = context.read<StudentProvider>().currentStudent;
    final studentId = currentStudent?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('My Requests', style: TextStyle(fontWeight: FontWeight.w700, color: primaryBlue)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlue),
      ),
      body: studentId.isEmpty
          ? const Center(child: Text('Student not logged in.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('studentId', isEqualTo: studentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading requests.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryBlue));
                }

                var docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No requests found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort locally by submissionDate descending
                final sortedDocs = docs.toList()..sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final dateA = dataA['submissionDate'] ?? '';
                  final dateB = dataB['submissionDate'] ?? '';
                  return dateB.compareTo(dateA); 
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final data = sortedDocs[index].data() as Map<String, dynamic>;
                    final docId = sortedDocs[index].id;
                    return _RequestHistoryCard(data: data, docId: docId);
                  },
                );
              },
            ),
    );
  }
}

class _RequestHistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _RequestHistoryCard({required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    final String subject = data['subject'] ?? 'No Subject';
    final String status = data['status'] ?? 'Pending';
    final String facultyName = data['currentHandlerName'] ?? 'Unknown Faculty';
    final String content = data['requestContent'] ?? '';
    final String dateStr = data['submissionDate'] ?? '';
    DateTime? date;
    if (dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr);
    }
    final String rejectedBy = data['rejectedBy'] ?? '';
    final String rejectionReason = data['rejectionReason'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'To: $facultyName',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF344054),
                height: 1.4,
              ),
            ),
            if (status.contains('Rejected') && rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason ($rejectedBy): $rejectionReason',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Color(0xFF98A2B3)),
                const SizedBox(width: 6),
                Text(
                  date != null ? DateFormat('MMM dd, yyyy').format(date) : '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (status == 'Approved') ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _downloadRequest(context),
                    icon: const Icon(Icons.download_rounded, size: 18, color: Colors.green),
                    label: const Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.green, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Approved')) return Colors.green;
    if (status.contains('Rejected')) return Colors.red;
    if (status.contains('Forwarded')) return Colors.orange;
    return const Color(0xFF174EA6);
  }

  Future<void> _downloadRequest(BuildContext context) async {
    final String subject = data['subject'] ?? 'No Subject';
    final String content = data['requestContent'] ?? '';
    final String dateStr = data['submissionDate'] ?? '';
    DateTime? date;
    if (dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr);
    }
    final String studentName = data['studentName'] ?? 'Student';
    final String studentId = data['studentId'] ?? '';
    final String approvedBy = data['approvedBy'] ?? 'Unknown Faculty';
    final String approvedDateTimeStr = data['approvedDateTime'] ?? '';
    DateTime? approvedDate;
    if (approvedDateTimeStr.isNotEmpty) {
      approvedDate = DateTime.tryParse(approvedDateTimeStr);
    }
    final String dateFormatted = date != null ? DateFormat('MMMM dd, yyyy').format(date) : 'N/A';
    final String approvedDateFormatted = approvedDate != null
        ? DateFormat('MMMM dd, yyyy hh:mm a').format(approvedDate)
        : 'N/A';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context pwContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header banner
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF174EA6),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'OFFICIAL REQUEST LETTER',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Approved Request ID: $docId',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Student details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STUDENT INFORMATION',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF667085),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        studentName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF101828),
                        ),
                      ),
                      pw.Text(
                        'ID: $studentId',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromInt(0xFF344054),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SUBMISSION DATE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF667085),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        dateFormatted,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF101828),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColor.fromInt(0xFFE4E7EC)),
              pw.SizedBox(height: 16),

              // Request Subject
              pw.Text(
                'SUBJECT',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF667085),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                subject,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF101828),
                ),
              ),
              pw.SizedBox(height: 20),

              // Request Content
              pw.Text(
                'CONTENT',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF667085),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF8F9FA),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE4E7EC)),
                ),
                child: pw.Text(
                  content,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromInt(0xFF344054),
                    lineSpacing: 4,
                  ),
                ),
              ),
              pw.SizedBox(height: 32),

              // Status and Approval details
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE8F5E9),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFA5D6A7)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'STATUS: APPROVED',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF2E7D32),
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Approved By: $approvedBy',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF1B5E20),
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Approved On: $approvedDateFormatted',
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF1B5E20),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final filename = 'Approved_Request_$docId.pdf';

    try {
      final bytes = await pdf.save();
      final path = await downloadRequestBytes(filename: filename, bytes: bytes);
      if (!context.mounted) return;

      final parts = path.split('/');
      final displayFilename = parts.isNotEmpty ? parts.last : filename;
      final simplifiedPath = path.toLowerCase().contains('/downloads/')
          ? 'Downloads/$displayFilename'
          : path.toLowerCase().contains('/documents/')
              ? 'Documents/$displayFilename'
              : displayFilename;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request downloaded to: $simplifiedPath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
