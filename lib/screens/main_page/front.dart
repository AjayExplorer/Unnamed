import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/student_provider.dart';
//import 'package:Unnamed/screens/request_letter/student/student_request.dart';
class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  int _selectedTab = 0;
  bool _didLoadNews = false;

  final List<_FeatureTileData> _featureTiles = const [
    _FeatureTileData(
      'Request\nLetter',
      Icons.description_outlined,
      Color(0xFF1E5CB3),
      Colors.white,
    ),
    _FeatureTileData(
      'Green\nCampus',
      Icons.eco_outlined,
      Color(0xFF31A25C),
      Colors.white,
    ),
    _FeatureTileData(
      'Lost &\nFound',
      Icons.search_outlined,
      Color(0xFFF2BE2B),
      Color(0xFF17212D),
    ),
    _FeatureTileData(
      'Food\nSharing',
      Icons.restaurant_outlined,
      Color(0xFFF2993E),
      Colors.white,
    ),
    _FeatureTileData(
      'Ride\nSharing',
      Icons.directions_car_outlined,
      Color(0xFF2AADC4),
      Colors.white,
    ),
    _FeatureTileData(
      'Events',
      Icons.calendar_month_outlined,
      Color(0xFFF6B186),
      Color(0xFF17212D),
    ),
    _FeatureTileData(
      'Bus\nTracking',
      Icons.directions_bus_outlined,
      Color(0xFFE9E0F8),
      Color(0xFF17212D),
    ),
    _FeatureTileData(
      'News',
      Icons.feed_outlined,
      Color(0xFFD8ECE0),
      Color(0xFF17212D),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadNews) {
      _didLoadNews = true;
      context.read<NewsProvider>().loadNewsPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final newsProvider = context.watch<NewsProvider>();
    final currentStudent = studentProvider.currentStudent;
    final displayName = _displayName(currentStudent?.fullName ?? 'Student');
    final photoUrl = currentStudent?.photoUrl ?? '';
    final featured = newsProvider.posts.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFE9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(displayName, photoUrl),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9F7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _featureTiles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.88,
                          ),
                      itemBuilder: (context, index) {
                        final tile = _featureTiles[index];
                        return _FeatureCard(
                          data: tile,
                          onTap: () {
                            if (tile.title.contains('News')) {
                              Navigator.of(context).pushNamed('/news');
                            } else if (tile.title.toLowerCase().contains('request')) {
                              Navigator.of(context).pushNamed('/student_request');
                            } else if (tile.title.contains('Events')) {
                              Navigator.of(context).pushNamed('/events');
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hello $displayName!',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Color(0xFF101828),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Latest Activities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildActivityCard(),
                    const SizedBox(height: 18),
                    const Text(
                      'Featured News',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (newsProvider.isLoading)
                      const SizedBox(
                        height: 112,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (newsProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                        ),
                        child: Text(
                          newsProvider.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      )
                    else if (featured.isEmpty)
                      const Text(
                        'No news available. Tap News to add a post.',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 14,
                        ),
                      )
                    else
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: featured.length,
                          separatorBuilder: (context, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            return _NewsCard(
                              title: featured[index].title,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (value) {
          if (value == 1) {
            Navigator.of(context).pushNamed('/student_history');
            return;
          }
          if (value == 2) {
            Navigator.of(context).pushNamed('/alerts');
            return;
          }

          if (value == 3) {
            Navigator.of(context).pushNamed('/profile');
            return;
          }

          setState(() => _selectedTab = value);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5A7A5E),
        unselectedItemColor: const Color(0xFF344054),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String displayName, String photoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB4CAB8), Color(0xFFA4C3AC)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: const Icon(Icons.school, color: Color(0xFF1E5CB3), size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hello\n$displayName!',
              style: const TextStyle(
                color: Color(0xFF101828),
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/alerts'),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF344054),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 20,
              foregroundImage: photoUrl.trim().isEmpty
                  ? null
                  : NetworkImage(photoUrl),
              backgroundColor: const Color(0xFFD8ECE0),
              child: const Icon(Icons.person, color: Color(0xFF344054)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFF344054),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return 'Student';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.first;
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2F6BDA), Color(0xFF174EA6)],
              ),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salare noor! Naila Sarsh!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Department of Merrio casior',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFFEAECEF), Color(0xFFD6DCE3)],
              ),
            ),
            child: const Icon(Icons.chevron_right, color: Color(0xFF344054)),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data, this.onTap});

  final _FeatureTileData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, color: data.foreground, size: 30),
            const SizedBox(height: 6),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: data.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF5A7A5E),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const Spacer(),
          const Text(
            'Tap to read more',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTileData {
  const _FeatureTileData(
    this.title,
    this.icon,
    this.background,
    this.foreground,
  );

  final String title;
  final IconData icon;
  final Color background;
  final Color foreground;
}
