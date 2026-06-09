import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Color> _pastelColors = const [
    Color(0xFFB2F5EA), // Mint Green
    Color(0xFFBEE3F8), // Light Blue
    Color(0xFFE0BBE4), // Lavender
    Color(0xFFFFE5D9), // Soft Peach
    Color(0xFFB5F5EC), // Light Teal
  ];

  @override
  void initState() {
    super.initState();
    // Clean up expired events when the page loads.
    _purgeExpiredEvents();
  }

  Future<void> _purgeExpiredEvents() async {
    final now = Timestamp.now();
    final query = FirebaseFirestore.instance
        .collection('events')
        .where('eventDate', isLessThan: now);
    final snapshots = await query.get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  void _showAddEventDialog() {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final hostCtrl = TextEditingController();
  final photoCtrl = TextEditingController();
  final regCtrl = TextEditingController();
  DateTime? selectedDate;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Event',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hostCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Hosted By',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: photoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Event Photo URL (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Registration Link (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Event Date'),
                    subtitle: Text(selectedDate == null
                        ? 'No date chosen'
                        : DateFormat.yMMMMd().format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          String photoUrlText = photoCtrl.text.trim();
                          if (photoUrlText.isNotEmpty &&
                              !photoUrlText.startsWith('http://') &&
                              !photoUrlText.startsWith('https://')) {
                            photoUrlText = 'https://' + photoUrlText;
                          }

                          String regLinkText = regCtrl.text.trim();
                          if (regLinkText.isNotEmpty &&
                              !regLinkText.startsWith('http://') &&
                              !regLinkText.startsWith('https://')) {
                            regLinkText = 'https://' + regLinkText;
                          }

                          await FirebaseFirestore.instance.collection('events').add({
                            'eventName': nameCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'hostedBy': hostCtrl.text.trim(),
                            'eventDate': Timestamp.fromDate(selectedDate!),
                            'createdAt': Timestamp.now(),
                            'photoUrl': photoUrlText,
                            'registrationLink': regLinkText,
                          });
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Add Event'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  String _daysRemaining(Timestamp eventTimestamp) {
    final now = DateTime.now();
    final eventDate = eventTimestamp.toDate();
    final diff = eventDate.difference(now).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return '1 Day Left';
    return '$diff Days Left';
  }

  Color _badgeColor(int days) {
    if (days < 3) return Colors.redAccent;
    if (days < 7) return Colors.orangeAccent;
    return Colors.green;
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  Widget _buildBrokenImageContainer(String url) {
    return Container(
      height: 150,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.grey, size: 36),
          const SizedBox(height: 8),
          Text(
            'Failed to load image:\n$url',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search events',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('eventDate')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                // Apply search filter
                final query = _searchController.text.toLowerCase();
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['eventName'] ?? '').toString().toLowerCase();
                  final host = (data['hostedBy'] ?? '').toString().toLowerCase();
                  return name.contains(query) || host.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No Upcoming Events'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showAddEventDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Event'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final eventName = data['eventName'] ?? '';
                    final description = data['description'] ?? '';
                    final hostedBy = data['hostedBy'] ?? '';
                    final eventTimestamp = data['eventDate'] as Timestamp;
                    final photoUrl = data['photoUrl'] ?? '';
                    final registrationLink = data['registrationLink'] ?? '';
                    final days = eventTimestamp.toDate().difference(DateTime.now()).inDays;
                    final badgeText = _daysRemaining(eventTimestamp);
                    final badgeCol = _badgeColor(days);
                    final cardColor = _pastelColors[index % _pastelColors.length];

                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (photoUrl.trim().isNotEmpty)
                            _isValidImageUrl(photoUrl.trim())
                                ? Image.network(
                                    photoUrl.trim(),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildBrokenImageContainer(photoUrl.trim()),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 150,
                                        color: Colors.grey.shade100,
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                : _buildBrokenImageContainer(photoUrl.trim()),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        eventName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeCol,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        badgeText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(description),
                                const SizedBox(height: 8),
                                Text('Hosted By: $hostedBy'),
                                const SizedBox(height: 4),
                                Text('Date: ${DateFormat.yMMMMd().format(eventTimestamp.toDate())}'),
                                if (registrationLink.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final Uri uri = Uri.parse(registrationLink);
                                        try {
                                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Could not launch $registrationLink')),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: $e')),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Register for Event'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                                        foregroundColor: Colors.black87,
                                        elevation: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
