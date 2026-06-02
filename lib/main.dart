import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Login_page/index.dart';
import 'screens/request_letter/faculty/providers/auth_provider.dart';
import 'screens/request_letter/faculty/providers/request_provider.dart';
import 'screens/request_letter/faculty/providers/availability_provider.dart';

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
      title: 'College System',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF174EA6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174EA6)),
      ),
      home: const LoginPage(),
    );
  }
}
