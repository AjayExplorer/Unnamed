import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';
import '../models/food_post.dart';
import '../services/food_sharing_service.dart';
import '../widgets/quotes_carousel.dart';
import '../widgets/food_post_card.dart';
import 'share_food_form_screen.dart';

class FoodSharingHomeScreen extends StatefulWidget {
  const FoodSharingHomeScreen({super.key});

  @override
  State<FoodSharingHomeScreen> createState() => _FoodSharingHomeScreenState();
}

class _FoodSharingHomeScreenState extends State<FoodSharingHomeScreen> {
  final FoodSharingService _service = FoodSharingService();
  String _searchQuery = '';
  String _filterType = 'All'; // 'All', 'Veg', 'Non-Veg'

  @override
  void initState() {
    super.initState();
    // Periodically/initially clean up expired food posts from the database
    _cleanupExpiredPosts();
  }

  Future<void> _cleanupExpiredPosts() async {
    await _service.deleteExpiredPosts();
  }

  Future<void> _handleRefresh() async {
    await _cleanupExpiredPosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudentName = studentProvider.currentStudent?.fullName ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9F7),
      appBar: AppBar(
        title: const Text(
          'Food Sharing Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded),
            tooltip: 'Clean Expired Posts',
            onPressed: () {
              _cleanupExpiredPosts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checking and cleaning expired food posts...'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Inspirational Quote Carousel
            const QuotesCarousel(),

            // Search Bar & Filter Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by pickup place...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filter veg/non-veg chips
                      Row(
                        children: ['All', 'Veg', 'Non-Veg'].map((type) {
                          final isSelected = _filterType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              selectedColor: const Color(0xFF2C5E3B),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black87),
                              ),
                              backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _filterType = type;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Live posts stream listing
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFF2C5E3B),
                child: StreamBuilder<List<FoodPost>>(
                  stream: _service.streamActiveFoodPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading food posts: ${snapshot.error}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final allPosts = snapshot.data ?? [];

                    // Apply filters client-side
                    final filteredPosts = allPosts.where((post) {
                      // Expiry filter (additional safety check, though stream should exclude)
                      if (post.pickupTimestamp.isBefore(DateTime.now())) {
                        return false;
                      }

                      // Type filter
                      if (_filterType != 'All' && post.foodType != _filterType) {
                        return false;
                      }

                      // Search filter
                      if (_searchQuery.isNotEmpty &&
                          !post.pickupPlace.toLowerCase().contains(_searchQuery)) {
                        return false;
                      }

                      return true;
                    }).toList();

                    // Header for count
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Available Food: ${filteredPosts.length} posts',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredPosts.isEmpty
                              ? _buildEmptyState(isDark)
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: filteredPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = filteredPosts[index];
                                    final canDelete = post.sharedBy == currentStudentName;

                                    return FoodPostCard(
                                      post: post,
                                      onDelete: canDelete
                                          ? () => _deletePost(post.id)
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShareFoodFormScreen(),
            ),
          );
          if (result == true) {
            _cleanupExpiredPosts();
          }
        },
        backgroundColor: const Color(0xFF2C5E3B),
        foregroundColor: Colors.white,
        tooltip: 'Share Food',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2F3E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 80,
                  color: Color(0xFF2C5E3B),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '🍽️ No food available currently',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Let's reduce food waste by sharing food with others.",
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deletePost(String? id) async {
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Post?'),
        content: const Text('Are you sure you want to delete this food post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteFoodPost(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food post deleted successfully.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete post: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
