import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_post.dart';

class FoodPostCard extends StatelessWidget {
  final FoodPost post;
  final VoidCallback? onDelete;

  const FoodPostCard({
    super.key,
    required this.post,
    this.onDelete,
  });

  String _formatPostedTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVeg = post.foodType.toLowerCase() == 'veg';
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(
              color: isVeg ? const Color(0xFF2C5E3B) : const Color(0xFFC62828),
              width: 6,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Food Type badge and Posted Time / Delete button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isVeg ? const Color(0xFFE2F3E8) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVeg ? Icons.eco_rounded : Icons.restaurant_rounded,
                          size: 16,
                          color: isVeg ? const Color(0xFF2C5E3B) : const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.foodType,
                          style: TextStyle(
                            color: isVeg ? const Color(0xFF2C5E3B) : const Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatPostedTime(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        )
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pickup Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.pickupPlace,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Pickup Time
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "Pickup: ${post.pickupTime}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Shared By info
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "Shared by: ${post.sharedBy}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),

              // Contact row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF1E5CB3)),
                      const SizedBox(width: 8),
                      Text(
                        post.phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E5CB3),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Action to copy phone number
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Copied ${post.phoneNumber} to clipboard!"),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text("Copy Number"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
