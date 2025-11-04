import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/screens/auth/login_screen.dart';
import 'package:projek_akhir_mobile/screens/auth/register_screen.dart';
import 'package:projek_akhir_mobile/screens/home/home_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/kalkulator_zakat_mal.dart';
import 'package:projek_akhir_mobile/screens/pages/detail_hafalan_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/developer_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/catatan_lokasi_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/kesan_pesan_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/list_hafalan_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/list_user_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/navigasi_screen.dart';
import 'package:projek_akhir_mobile/screens/pages/tambah_screen.dart';
import 'package:projek_akhir_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projek Akhir Mobile',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0057FF),
        ),
        useMaterial3: true,
      ),
      
      home: FutureBuilder<String?>(
        future: _checkToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const NavigasiScreen();
          } 
          else {
            return const LoginScreen();
          }
        },
      ),
      
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dev': (context) => const DeveloperScreen(),
        '/kesan': (context) => const KesanTpmScreen(),
        '/kalkulator': (context) => const kalkulatorScreen(), 
        '/user': (context) => const ListUserScreen(),
        '/hafalan': (context) => const ListHafalanScreen(),
        '/tambah': (context) => const TambahScreen(),
        '/detail': (context) => const DetailHafalanScreen(),
        '/jadwal': (context) => const JadwalPembayaranScreen(),
      },
    );
  }
}