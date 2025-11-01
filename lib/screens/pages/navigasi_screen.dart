// lib/screens/pages/navigasi_screen.dart

import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Tidak perlu lagi
// import 'package:projek_akhir_mobile/screens/auth/login_screen.dart'; // Tidak perlu lagi
import 'package:projek_akhir_mobile/screens/home/profile_screen.dart';
import 'package:projek_akhir_mobile/screens/home/list_screen.dart';
import '../home/home_screen.dart';

class NavigasiScreen extends StatefulWidget {
  const NavigasiScreen({super.key});

  @override
  State<NavigasiScreen> createState() => _NavigasiScreenState();
}

class _NavigasiScreenState extends State<NavigasiScreen> {
  int _currentIndex = 1;

  List<Widget> get _pages => [ListScreen(), HomeScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: _pages.elementAt(_currentIndex))),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}