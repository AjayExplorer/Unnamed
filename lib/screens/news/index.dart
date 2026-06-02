import 'package:flutter/material.dart';
import 'package:openpro/models/news_feed.dart';
import 'package:openpro/models/user_profile.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Event');

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text('News Section'),
        backgroundColor: const Color(0xFFA4C3AC),
        foregroundColor: const Color(0xFF101828),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNews,
        backgroundColor: const Color(0xFF174EA6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create News'),
      ),
      body: ValueListenableBuilder<List<NewsPost>>(
        valueListenable: newsFeedNotifier,
        builder: (context, feed, _) {
          if (feed.isEmpty) {
            return const Center(
              child: Text(
                'No news yet. Create one from the button below.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: feed.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final post = feed[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F0FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            post.category,
                            style: const TextStyle(
                              color: Color(0xFF174EA6),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          post.timeLabel,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.details,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Posted by ${post.author}',
                      style: const TextStyle(
                        color: Color(0xFF344054),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _createNews() {
    _titleController.clear();
    _detailsController.clear();
    _categoryController.text = 'Event';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create News Post',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              const SizedBox(height: 12),
              _inputField('Title', _titleController),
              const SizedBox(height: 10),
              _inputField('Category', _categoryController),
              const SizedBox(height: 10),
              _inputField('Details', _detailsController, maxLines: 4),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final details = _detailsController.text.trim();
                    final category = _categoryController.text.trim();

                    if (title.isEmpty || details.isEmpty || category.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill title, category and details',
                          ),
                        ),
                      );
                      return;
                    }

                    final updatedFeed = [
                      NewsPost(
                        title: title,
                        details: details,
                        category: category,
                        author: _authorName(),
                        postedAt: DateTime.now(),
                      ),
                      ...newsFeedNotifier.value,
                    ];

                    newsFeedNotifier.value = updatedFeed;

                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('News posted to the app')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF174EA6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Post News'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _authorName() {
    final name = userProfileNotifier.value.name.trim();
    if (name.isEmpty) {
      return 'Anonymous';
    }
    return name;
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
