import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/models/lokasi_model.dart';
import 'package:projek_akhir_mobile/services/lokasi_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class JadwalPembayaranScreen extends StatefulWidget {
  const JadwalPembayaranScreen({super.key});

  @override
  State<JadwalPembayaranScreen> createState() => _JadwalPembayaranScreenState();
}

class _JadwalPembayaranScreenState extends State<JadwalPembayaranScreen> {
  final LokasiService _lokasiService = LokasiService();
  late Future<List<LokasiModel>> _futureLokasiList;
  bool _isLoading = false;
  final Color _primaryColor = const Color(0xFF044C9C);

  @override
  void initState() {
    super.initState();
    cekSession();
    _loadCatatan();
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _loadCatatan() {
    setState(() {
      _futureLokasiList = _lokasiService.getSemuaLokasi();
    });
  }

  Future<void> _tambahCatatanLokasi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position pos = await _determinePosition();
      DateTime waktuSekarang = DateTime.now();
      String alamat =
          await _lokasiService.getAlamatFromKoordinat(pos.latitude, pos.longitude);

      final list = await _lokasiService.getSemuaLokasi();
      int newId = (list.isNotEmpty) ? list.last.id + 1 : 1;

      LokasiModel catatanBaru = LokasiModel(
        id: newId,
        waktuCatat: waktuSekarang.toIso8601String(),
        latitude: pos.latitude,
        longitude: pos.longitude,
        alamat: alamat,
      );

      await _lokasiService.simpanLokasi(catatanBaru);

      _loadCatatan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Catatan Lokasi & Waktu'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<LokasiModel>>(
        future: _futureLokasiList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan lokasi'));
          }

          final catatanList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: catatanList.length,
            itemBuilder: (context, index) {
              final catatan = catatanList[index];
              final waktuUtc = DateTime.parse(catatan.waktuCatat).toUtc();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor.withOpacity(0.1),
                          child: Icon(Icons.location_on, color: _primaryColor),
                        ),
                        title: Text(
                          catatan.alamat,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Lat: ${catatan.latitude.toStringAsFixed(5)}, Lon: ${catatan.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      
                      const Divider(height: 24),

                      _buildInfoWaktu(
                        'WIB (Jakarta)',
                        waktuUtc,
                        'Asia/Jakarta',
                      ),
                      _buildInfoWaktu(
                        'WITA (Makassar)',
                        waktuUtc,
                        'Asia/Makassar',
                      ),
                      _buildInfoWaktu(
                        'WIT (Jayapura)',
                        waktuUtc,
                        'Asia/Jayapura',
                      ),
                      _buildInfoWaktu(
                        'London (UK)',
                        waktuUtc,
                        'Europe/London',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _tambahCatatanLokasi,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_location_alt),
      ),
    );
  }

  Widget _buildInfoWaktu(String label, DateTime waktuUtc, String locationName) {
    final location = tz.getLocation(locationName);
    final waktuLokal = tz.TZDateTime.from(waktuUtc, location);
    final String formattedTime =
        DateFormat('d MMM yyyy, HH:mm:ss').format(waktuLokal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}