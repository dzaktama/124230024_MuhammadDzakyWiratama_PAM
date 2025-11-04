import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/components/menu_list.dart';
import 'package:projek_akhir_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir_mobile/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NotificationService _notificationService = NotificationService();
  final Color _primaryColor = const Color(0xFF044C9C);

  @override
  void initState() {
    super.initState();
    cekSession();
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token'); 
    await prefs.remove('username');
    await prefs.remove('token');
    await _notificationService.flutterLocalNotificationsPlugin.cancelAll();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _showNotification() async {
    await _notificationService.showNotification(
      id: 0,
      title: 'Test Notifikasi',
      body: 'muncul donggg notifnya',
      payload: 'data tambahan',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          MenuList(
            title: "Profil Developer",
            icon: Icons.person_outline,
            onPress: () {
              Navigator.pushNamed(context, '/dev');
            },
          ),
          MenuList(
            title: "Kesan dan Pesan",
            icon: Icons.feedback_outlined,
            onPress: () {
              Navigator.pushNamed(context, '/kesan');
            },
          ),
          MenuList(
            title: "Kalkulator Zakat Mal",
            icon: Icons.calculate_outlined,
            onPress: () {
              Navigator.pushNamed(context, '/kalkulator');
            },
          ),
          MenuList(
            title: "Catatan Lokasi & Waktu",
            icon: Icons.location_history_outlined,
            onPress: () {
              Navigator.pushNamed(context, '/jadwal');
            },
          ),
          MenuList(
            title: "List Akun",
            icon: Icons.group_outlined,
            onPress: () {
              Navigator.pushNamed(context, '/user');
            },
          ),
          MenuList(
            title: "List Hafalan",
            icon: Icons.book_outlined,
            onPress: () {
              Navigator.pushNamed(context, '/hafalan');
            },
          ),
          MenuList(
            title: "Test Notifikasi",
            icon: Icons.notifications_active_outlined,
            onPress: () async {
              await _showNotification();
            },
          ),
        ],
      ),
    );
  }
}