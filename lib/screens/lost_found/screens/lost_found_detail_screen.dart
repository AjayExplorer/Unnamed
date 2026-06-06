import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lost_found_item.dart';
import '../providers/lost_found_provider.dart';
import '../../../providers/student_provider.dart';

class LostFoundDetailScreen extends StatelessWidget {
  const LostFoundDetailScreen({super.key, required this.item});

  final LostFoundItem item;

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == 'lost';
    final accentColor =
        isLost ? const Color(0xFFEF6C50) : const Color(0xFF31A25C);
    final hasImage = item.imageUrl.trim().isNotEmpty;

    // Determine ownership
    final studentProvider = context.read<StudentProvider>();
    final currentStudent = studentProvider.currentStudent;
    final currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? currentStudent?.id ?? '';
    final isOwner = item.createdBy == currentUid;
    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isLost ? 'Lost Item' : 'Found Item',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context, currentUid),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image / placeholder ──
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: hasImage
                    ? null
                    : Center(
                        child: Icon(
                          isLost
                              ? Icons.search_off_rounded
                              : Icons.emoji_objects_rounded,
                          color: accentColor.withValues(alpha: 0.25),
                          size: 72,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // ── Tag + date row ──
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLost ? 'LOST' : 'FOUND',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time_rounded,
                      color: Color(0xFF667085), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatFullDate(item.createdAt),
                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Keyword / Title ──
              Text(
                item.keyword,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // ── Description ──
              Text(
                item.description,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // ── Posted by ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child:
                          Icon(Icons.person_rounded, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Posted by',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.createdByName,
                            style: const TextStyle(
                              color: Color(0xFF101828),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Copy image URL ──
              if (hasImage)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accentColor.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.copy_rounded, color: accentColor, size: 18),
                    label: Text(
                      'Copy Image URL',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.imageUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image URL copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF31A25C),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String currentUid) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Post?',
            style: TextStyle(color: Color(0xFF101828), fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'This action cannot be undone. Are you sure you want to delete this post?',
            style: TextStyle(color: Color(0xFF667085)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF667085))),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // close dialog
                final provider = context.read<LostFoundProvider>();
                final success =
                    await provider.deleteItem(item.id, currentUid);
                if (!context.mounted) return;
                if (success) {
                  Navigator.of(context).pop(); // go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFFEF6C50),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(provider.errorMessage ?? 'Failed to delete'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFFEF6C50),
                    ),
                  );
                }
              },
              child: const Text('Delete',
                  style: TextStyle(
                      color: Color(0xFFEF6C50), fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} · ${h == 0 ? 12 : h}:$min $amPm';
  }
}
