import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const newsItems = [
      (
        'Tech Fest starts this Friday',
        'Campus activities committee announced workshops and hackathon tracks.',
        '2h ago',
      ),
      (
        'New bus route added for hostellers',
        'Morning and evening shuttle timings updated in transport office portal.',
        '5h ago',
      ),
      (
        'Library will be open till 10 PM',
        'Extended timings start this week for semester exam preparation.',
        '1d ago',
      ),
      (
        'Placement training registration open',
        'Students can enroll before Thursday through the request portal.',
        '1d ago',
      ),
      (
        'Green campus clean-up campaign',
        'Volunteer slots are available for Saturday between 8 AM and 12 PM.',
        '2d ago',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text('Alerts & News'),
        elevation: 0,
        backgroundColor: const Color(0xFFA4C3AC),
        foregroundColor: const Color(0xFF101828),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: newsItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = newsItems[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4E7EC)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF31A25C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF667085),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F6BDA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
