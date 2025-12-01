import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _pages[_selectedIndex]);
  }
}
