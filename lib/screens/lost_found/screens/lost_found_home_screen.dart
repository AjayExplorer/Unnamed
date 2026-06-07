import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lost_found_item.dart';
import '../providers/lost_found_provider.dart';
import '../../../providers/student_provider.dart';
import 'lost_found_detail_screen.dart';

class LostAndFoundHomeScreen extends StatefulWidget {
  const LostAndFoundHomeScreen({super.key});

  @override
  State<LostAndFoundHomeScreen> createState() => _LostAndFoundHomeScreenState();
}

class _LostAndFoundHomeScreenState extends State<LostAndFoundHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _didInitLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitLoad) {
      _didInitLoad = true;
      context.read<LostFoundProvider>().loadItems();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemSheet(BuildContext context, String type) {
    final keywordCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E7EC),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        type == 'lost'
                            ? 'Report Lost Item'
                            : 'Report Found Item',
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: keywordCtrl,
                        label: 'Item Name / Keyword',
                        hint: 'e.g. Blue Backpack',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: descCtrl,
                        label: 'Description',
                        hint: 'Where you lost / found it, any details…',
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: imageUrlCtrl,
                        label: 'Image URL (optional)',
                        hint: 'https://example.com/photo.jpg',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: type == 'lost'
                                ? const Color(0xFFEF6C50)
                                : const Color(0xFF31A25C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _submitItem(
                            ctx,
                            formKey,
                            type,
                            keywordCtrl.text,
                            descCtrl.text,
                            imageUrlCtrl.text,
                          ),
                          child: Text(
                            type == 'lost'
                                ? 'Post Lost Item'
                                : 'Post Found Item',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF101828)),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
            filled: true,
            fillColor: const Color(0xFFF1F3F4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitItem(
    BuildContext ctx,
    GlobalKey<FormState> formKey,
    String type,
    String keyword,
    String description,
    String imageUrl,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final studentProvider = context.read<StudentProvider>();
    final currentStudent = studentProvider.currentStudent;
    final uid =
        FirebaseAuth.instance.currentUser?.uid ?? currentStudent?.id ?? '';
    final name = currentStudent?.fullName ?? 'Unknown';

    final createdAt = DateTime.now();
    final item = LostFoundItem(
      id: '',
      type: type,
      keyword: keyword.trim(),
      description: description.trim(),
      imageUrl: imageUrl.trim(),
      createdBy: uid,
      createdByName: name,
      createdAt: createdAt,
      expiresAt: createdAt.add(const Duration(days: 2)),
    );

    final provider = context.read<LostFoundProvider>();
    final success = await provider.addItem(item);

    if (!ctx.mounted) return;
    Navigator.of(ctx).pop();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type == 'lost' ? 'Lost' : 'Found'} item posted!'),
          backgroundColor: const Color(0xFF31A25C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSortDialog(BuildContext context) {
    final provider = context.read<LostFoundProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sort By',
            style: TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            _sortOption(ctx, provider, 'latest', 'Latest First'),
            _sortOption(ctx, provider, 'oldest', 'Oldest First'),
            _sortOption(ctx, provider, 'alphabetical', 'A → Z'),
          ],
        );
      },
    );
  }

  Widget _sortOption(
    BuildContext ctx,
    LostFoundProvider provider,
    String value,
    String label,
  ) {
    final isSelected = provider.sortBy == value;
    final themeColor = provider.selectedType == 'lost'
        ? const Color(0xFFEF6C50)
        : const Color(0xFF31A25C);
    return SimpleDialogOption(
      onPressed: () {
        provider.setSortBy(value);
        Navigator.of(ctx).pop();
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? themeColor : const Color(0xFF98A2B3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF101828)
                  : const Color(0xFF667085),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LostFoundProvider>();
    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lost & Found',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: () => _showSortDialog(context),
            tooltip: 'Sort',
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
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _tabButton(
                      'lost',
                      'Lost',
                      const Color(0xFFEF6C50),
                      provider,
                    ),
                    _tabButton(
                      'found',
                      'Found',
                      const Color(0xFF31A25C),
                      provider,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
                onChanged: (val) =>
                    context.read<LostFoundProvider>().setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search items…',
                  hintStyle: const TextStyle(color: Color(0xFF667085)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF667085),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F4),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTypeChooser(context),
        backgroundColor: provider.selectedType == 'lost'
            ? const Color(0xFFEF6C50)
            : const Color(0xFF31A25C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Report',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showTypeChooser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E7EC),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'What would you like to report?',
                  style: TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _typeButton(
                        ctx,
                        'lost',
                        'I Lost Something',
                        Icons.search_off_rounded,
                        const Color(0xFFEF6C50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeButton(
                        ctx,
                        'found',
                        'I Found Something',
                        Icons.emoji_objects_rounded,
                        const Color(0xFF31A25C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _typeButton(
    BuildContext ctx,
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(ctx).pop();
        _showAddItemSheet(context, type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(
    String type,
    String label,
    Color activeColor,
    LostFoundProvider provider,
  ) {
    final isActive = provider.selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSelectedType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF667085),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LostFoundProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF174EA6)),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF6C50),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667085), fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => provider.loadItems(),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Color(0xFF174EA6)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              provider.selectedType == 'lost'
                  ? Icons.search_off_rounded
                  : Icons.emoji_objects_outlined,
              color: const Color(0xFF98A2B3),
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              provider.selectedType == 'lost'
                  ? 'No lost items reported yet'
                  : 'No found items reported yet',
              style: const TextStyle(color: Color(0xFF667085), fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the + button to report',
              style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return _ItemCard(
          item: item,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LostFoundDetailScreen(item: item),
            ),
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, this.onTap});

  final LostFoundItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == 'lost';
    final accentColor = isLost
        ? const Color(0xFFEF6C50)
        : const Color(0xFF31A25C);
    final hasImage = _hasValidImageUrl(item.imageUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 90,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hasImage
                    ? Image.network(
                        item.imageUrl.trim(),
                        width: 80,
                        height: 90,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              isLost
                                  ? Icons.search_off_rounded
                                  : Icons.emoji_objects_rounded,
                              color: accentColor.withValues(alpha: 0.4),
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          isLost
                              ? Icons.search_off_rounded
                              : Icons.emoji_objects_rounded,
                          color: accentColor.withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(item.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.keyword,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${item.createdByName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasValidImageUrl(String url) {
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
