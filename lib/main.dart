import 'package:flutter/material.dart';
import 'screens/Login_page/index.dart';
import 'screens/alerts/index.dart';
import 'screens/main_page/front.dart';
import 'screens/profile/index.dart';

void main() {
  runApp(const MyApp());
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
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
