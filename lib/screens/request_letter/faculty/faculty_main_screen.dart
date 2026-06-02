
import 'package:flutter/material.dart';
import 'screens/inbox_screen.dart';
import 'screens/leave_management_screen.dart';
import 'screens/profile_screen.dart';

class FacultyMainScreen extends StatefulWidget {
  const FacultyMainScreen({super.key});

  @override
  State<FacultyMainScreen> createState() => _FacultyMainScreenState();
}

class _FacultyMainScreenState extends State<FacultyMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const InboxScreen(),
    const LeaveManagementScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF174EA6);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF98A2B3),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_email_unread_outlined),
              activeIcon: Icon(Icons.mark_email_unread),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
