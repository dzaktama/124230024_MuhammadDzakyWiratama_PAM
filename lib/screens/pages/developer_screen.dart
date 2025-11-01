import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil Developer'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _anggotaList(
              "lib/assets/images/dzaky.jpg", 
              "Muhammad Dzaky Wiratama",
              "124230024",
            ),
            const SizedBox(height: 16),
            _buildBiodataCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(height: 1.4)),
    );
  }

  Widget _buildBiodataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Text(
                "Biodata Diri",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.school_outlined,
              "Universitas",
              "UPN \"Veteran\" Yogyakarta",
            ),
            _buildInfoRow(
              Icons.code_outlined,
              "Jurusan",
              "Sistem Informasi",
            ),
            _buildInfoRow(
              Icons.interests_outlined,
              "Hobi",
              "Hobi saya berlari, belajar, belajar, dan belajar.",
            ),
            _buildInfoRow(
              Icons.format_quote_outlined,
              "Motto",
              "Yang penting selesai. Walaupun ngerjain seminggu + laporan, dan gaikut uts, semoga bisa tetep dapet A hehe",
            ),
          ],
        ),
      ),
    );
  }

  Widget _anggotaList(String path, String nama, String nim) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.asset(
                  path,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.grey[600], size: 50),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text("NIM : $nim"),
          ],
        ),
      ),
    );
  }
}