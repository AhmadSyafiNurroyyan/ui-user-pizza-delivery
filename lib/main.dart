import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: primaryColor, useMaterial3: true),
      home: const WelcomeScreen(),
    );
  }
}
