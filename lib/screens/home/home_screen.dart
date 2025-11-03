import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/models/hafalan_model.dart';
import 'package:projek_akhir_mobile/models/user_model.dart';
import 'package:projek_akhir_mobile/models/ayat_random_model.dart';
import 'package:projek_akhir_mobile/services/hafalan_save.dart';
import 'package:projek_akhir_mobile/services/notification_service.dart';
import 'package:projek_akhir_mobile/services/user_save.dart';
import 'package:projek_akhir_mobile/services/surat_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir_mobile/screens/auth/login_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Hafalan>> _hafalanListFuture;
  Future<User?>? _userFuture;
  Future<AyatRandomModel?>? _ayatFuture;
  int _totalHafalan = 0;
  
  final NotificationService _notificationService = NotificationService();
  final Color _primaryColor = const Color(0xFF044C9C); 

  @override
  void initState() {
    super.initState();
    cekSession();
    _loadData();
  }

  void _loadData() {
    _hafalanListFuture = HafalanSave().getHafalanHariIni();
    _userFuture = _loadUserData();
    _ayatFuture = SuratNetwork().getAyatRandom();
    
    HafalanSave().getHafalan().then((list) {
      if (mounted) {
        setState(() {
          _totalHafalan = list.length;
        });
      }
    });
  }

  void _refreshAyat() {
    setState(() {
      _ayatFuture = SuratNetwork().getAyatRandom();
    });
  }

  Future<User?> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return null;
    
    return await UserSave().getUserByUsername(username);
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _fetchHafalanList() async {
    try {
      final list = await HafalanSave().getHafalanHariIni();
      setState(() {
        _hafalanListFuture = Future.value(list);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
      }
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token'); 
    await prefs.remove('username');
    await prefs.remove('token'); 
    await _notificationService.flutterLocalNotificationsPlugin.cancelAll();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${dateTime.day} ${_bulan(dateTime.month)} ${dateTime.year}";
    return formattedDate;
  }

  String _bulan(int bulan) {
    switch (bulan) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mar";
      case 4: return "Apr";
      case 5: return "Mei";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Agu";
      case 9: return "Sep";
      case 10: return "Okt";
      case 11: return "Nov";
      case 12: return "Des";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text("Homepage"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            FutureBuilder<User?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: const ListTile(
                      title: Text('Memuat data user...'),
                      subtitle: Text('...'),
                    ),
                  );
                }
                
                final user = snapshot.data;
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selamat Datang,",
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              Text(
                                user?.username ?? "User",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                              Text(
                                user?.email ?? "email...",
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: _primaryColor,
                          child: Text(
                            _totalHafalan.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 0, left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ayat Hari Ini',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: _primaryColor),
                    onPressed: _refreshAyat,
                  ),
                ],
              ),
            ),

            FutureBuilder<AyatRandomModel?>(
              future: _ayatFuture,
              builder: (context, snapshot) {
                Widget child;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  child = const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Memuat ayat..."),
                  ));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  child = const ListTile(
                    leading: Icon(Icons.error_outline, color: Colors.red),
                    title: Text("Gagal Memuat Ayat"),
                    subtitle: Text("Periksa koneksi internet Anda."),
                  );
                } else {
                  final ayat = snapshot.data!;
                  child = Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.format_quote_rounded, color: _primaryColor, size: 30),
                        const SizedBox(height: 12),
                        Text(
                          "\"${ayat.teks}\"",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "- ${ayat.namaSurat}, Ayat ${ayat.nomorAyat}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 150,
                    ),
                    child: child,
                  ),
                );
              },
            ),
            
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 12, left: 4),
              child: Text(
                'Hafalan Saya',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            FutureBuilder<List<Hafalan>>( 
              future: _hafalanListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _primaryColor));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Tidak Ada Data Hafalan Hari Ini'),
                    ),
                  );
                }

                final dataList = snapshot.data!;

                return ListView.builder(
                  itemCount: dataList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = dataList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: _primaryColor,
                          ),
                        ),
                        title: Text(
                          data.namaHafalan,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          '${_formatDate(data.tanggalMulai)} s/d ${_formatDate(data.tanggalSelesai)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: {
                              'id': data.id,
                              'idHafalan': data.idHafalan,
                              'tipeHafalan': data.tipeHafalan,
                            },
                          ).then((_) => _loadData()); 
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}