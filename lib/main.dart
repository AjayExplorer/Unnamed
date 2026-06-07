import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/Login_page/index.dart';
import 'screens/alerts/index.dart';
import 'screens/main_page/front.dart';
import 'screens/news/index.dart';
import 'screens/profile/index.dart';
import 'screens/event/event.dart';
import 'screens/request_letter/faculty/providers/auth_provider.dart';
import 'screens/request_letter/faculty/providers/request_provider.dart';
import 'screens/request_letter/faculty/providers/availability_provider.dart';
import 'screens/request_letter/faculty/providers/faculty_registration_provider.dart';
import 'screens/admin/providers/admin_provider.dart';
import 'screens/request_letter/student_registration/student_registration.dart';
import 'screens/request_letter/faculty/screens/faculty_registration_request_screen.dart';
import 'screens/admin/screens/admin_dashboard_screen.dart';
import 'screens/student_verification/student_verification.dart';
import 'providers/news_provider.dart';
import 'providers/student_provider.dart';
import 'screens/request_letter/student/student_request.dart';
import 'screens/request_letter/student/student_history.dart';
import 'screens/bus_tracking/providers/bus_tracking_provider.dart';
import 'screens/bus_tracking/screens/admin_driver_registration_screen.dart';
import 'screens/bus_tracking/screens/admin_bus_registration_screen.dart';
import 'screens/bus_tracking/screens/driver_dashboard_screen.dart';
import 'screens/bus_tracking/screens/driver_profile_screen.dart';
import 'screens/bus_tracking/screens/student_bus_home_screen.dart';
import 'screens/bus_tracking/screens/student_live_tracking_screen.dart';
import 'screens/lost_found/providers/lost_found_provider.dart';
import 'screens/lost_found/screens/lost_found_home_screen.dart';
import 'screens/food_sharing/screens/food_sharing_home_screen.dart';
import 'screens/green_campus/green_campus_screen.dart';
import 'screens/ride_sharing/screens/ride_sharing_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await fb_auth.FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    // Anonymous Auth failed on web for this build, but Firestore can still work
    // if the rules allow unauthenticated access during development.
    debugPrint('Firebase anonymous sign-in failed: $e');
  }

  // Ensure a default admin exists for development convenience.
  await _ensureDefaultAdminExists();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<RequestProvider>(create: (_) => RequestProvider()),
        ChangeNotifierProvider<AvailabilityProvider>(create: (_) => AvailabilityProvider()),
        ChangeNotifierProvider<FacultyRegistrationProvider>(create: (_) => FacultyRegistrationProvider()),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
        ChangeNotifierProvider<StudentProvider>(create: (_) => StudentProvider()),
        ChangeNotifierProvider<NewsProvider>(create: (_) => NewsProvider()),
        ChangeNotifierProvider<BusTrackingProvider>(create: (_) => BusTrackingProvider()),
        ChangeNotifierProvider<LostFoundProvider>(create: (_) => LostFoundProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _ensureDefaultAdminExists() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final admins = await firestore.collection('admins').limit(1).get();
    if (admins.docs.isEmpty) {
      // Default credentials (development only)
      final defaultAdmin = {
        'username': 'admin',
        'password': 'Admin@123',
        'name': 'Super Admin',
        'email': 'admin@example.com',
      };
      await firestore.collection('admins').doc().set(defaultAdmin);
      debugPrint('Inserted default admin (username: admin, password: Admin@123)');
    } else {
      debugPrint('Admin document(s) already present - skipping default admin creation.');
    }
  } catch (e) {
    debugPrint('Failed to ensure default admin exists: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CollabSolve',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174EA6)),
      ),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: mediaQueryData.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child!,
        );
      },
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/front': (context) => const FrontPage(),
        '/alerts': (context) => const AlertsPage(),
        '/news': (context) => const NewsPage(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const StudentRegistration(),
        '/faculty_register': (context) => const FacultyRegistrationRequestScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/verify': (context) => const StudentVerification(),
        '/student_request': (context) => const StudentRequestPage(),
        '/student_history': (context) => const StudentHistoryPage(),
        '/events': (context) => const EventsPage(),
        '/student_bus_tracking_home': (context) => const StudentBusHomeScreen(),
        '/student_live_tracking': (context) => const StudentLiveTrackingScreen(),
        '/driver_dashboard': (context) => const DriverDashboardScreen(),
        '/driver_profile': (context) => const DriverProfileScreen(),
        '/admin_driver_registration': (context) => const AdminDriverRegistrationScreen(),
        '/admin_bus_registration': (context) => const AdminBusRegistrationScreen(),
        '/lost_found': (context) => const LostAndFoundHomeScreen(),
        '/food_sharing': (context) => const FoodSharingHomeScreen(),
        '/green_campus': (context) => const GreenCampusScreen(),
        '/ride_sharing': (context) => const RideSharingHomeScreen(),
        // '/add-event': (context) => const AddEventPage(), // removed – using dialog in EventsPage
      },
    );
  }
}
