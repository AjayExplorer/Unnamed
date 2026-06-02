import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Login_page/index.dart';
import 'screens/alerts/index.dart';
import 'screens/main_page/front.dart';
import 'screens/news/index.dart';
import 'screens/profile/index.dart';
import 'screens/request_letter/faculty/providers/auth_provider.dart';
import 'screens/request_letter/faculty/providers/request_provider.dart';
import 'screens/request_letter/faculty/providers/availability_provider.dart';
import 'screens/request_letter/student_registration/student_registration.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/front': (context) => const FrontPage(),
        '/alerts': (context) => const AlertsPage(),
        '/news': (context) => const NewsPage(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const StudentRegistration(),
      },
    );
  }
}
