import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/models/hafalan_model.dart';
import 'package:projek_akhir_mobile/models/surat_detail_model.dart';
import 'package:projek_akhir_mobile/services/hafalan_save.dart';
import 'package:projek_akhir_mobile/services/surat_network.dart';
import 'package:projek_akhir_mobile/services/lokasi_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class DetailHafalanScreen extends StatefulWidget {
  const DetailHafalanScreen({super.key});

  @override
  State<DetailHafalanScreen> createState() => _DetailHafalanScreenState();
}

class _DetailHafalanScreenState extends State<DetailHafalanScreen> {
  Future<SuratDetail?>? _detailFuture;
  int? _id;
  int? _idHafalan;
  String? _locationMessage;

  final Color _primaryColor = const Color(0xFF044C9C);
  final _notesController = TextEditingController();
  final _ayatController = TextEditingController();
  final LokasiService _lokasiService = LokasiService();

  @override
  void initState() {
    super.initState();
    cekSession();
    _requestAndGetLocation();
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _idHafalan = args['idHafalan'] as int?;
      _id = args['id'] as int?;
    }

    if (_idHafalan != null) {
      _detailFuture = _fetchDetail(_idHafalan!);
    }

    if (_id != null) {
      _loadProgress();
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _notesController.text = prefs.getString('hafalan_note_$_id') ?? '';
    _ayatController.text = prefs.getString('hafalan_ayat_$_id') ?? '';
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hafalan_note_$_id', _notesController.text);
    await prefs.setString('hafalan_ayat_$_id', _ayatController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan progres disimpan!')),
      );
    }
  }

  Future<SuratDetail?> _fetchDetail(int id) {
    return SuratNetwork().getDetailData(id);
  }

  Future<void> _requestAndGetLocation() async {
    try {
      final pos = await _determinePosition();
      final String alamat = await _lokasiService.getAlamatFromKoordinat(
          pos.latitude, pos.longitude);

      if (mounted) {
        setState(() {
          _locationMessage = alamat;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationMessage = 'Gagal Mendapatkan Lokasi: $e';
        });
      }
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

  void selesaiHafalan() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) {
      debugPrint('No username found in SharedPreferences');
      return;
    }

    final List<Hafalan> hafalanList = await HafalanSave().getHafalan();
    final index = hafalanList.indexWhere((h) => h.id == _id);
    if (index == -1) {
      debugPrint('Hafalan dengan id=$_idHafalan tidak ditemukan');
      return;
    }

    Hafalan hafalan = hafalanList[index];
    DateTime tanggalMulai = DateTime.parse(hafalan.tanggalMulai);
    DateTime tanggalSelesai = DateTime.parse(hafalan.tanggalSelesai);

    tanggalMulai = tanggalMulai.add(const Duration(days: 1));
    if (tanggalMulai.isAfter(tanggalSelesai)) {
      hafalanList.removeAt(index);
    } else {
      hafalan.tanggalMulai = tanggalMulai.toIso8601String();
      hafalanList[index] = hafalan;
    }

    final success = await HafalanSave().saveHafalanList(hafalanList);
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      debugPrint('Gagal menyimpan perubahan');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _ayatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Hafalan Surat'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _detailFuture == null
          ? const Center(child: Text('Data tidak tersedia'))
          : FutureBuilder<SuratDetail?>(
              future: _detailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data == null) {
                  return const Center(child: Text('Tidak Ada Data'));
                }

                final surat = snapshot.data!;
                return _buildSuratDetail(surat);
              },
            ),
    );
  }

  Widget _buildSuratDetail(SuratDetail suratDetail) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '${suratDetail.namaLatin} - ${suratDetail.nama}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Surat ke - ${suratDetail.nomor}'),
                            Text('${suratDetail.jumlahAyat} Ayat'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Arti : ${suratDetail.arti}')),
                            Text('Turun di ${suratDetail.tempatTurun}',
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan Progres',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ayatController,
                          decoration: InputDecoration(
                            labelText: 'Ayat Terakhir Dihafal',
                            hintText: 'Misal: 15',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Catatan (opsional)',
                            hintText: 'Misal: Sulit di bagian tajwid...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveProgress,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Progres'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: _primaryColor),
                    title: const Text('Lokasi GPS (LBS)'),
                    subtitle: Text(
                      _locationMessage ?? 'Mencari lokasi...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 12, left: 4),
                  child: Text(
                    'Daftar Ayat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: suratDetail.ayat.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final ayat = suratDetail.ayat[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          "${ayat.nomorAyat}. ${ayat.teksArab}",
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black, height: 1.5),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            ayat.teksIndonesia,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        minLeadingWidth: 0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selesaiHafalan,
              label: const Text("Selesai Hafalan Surat"),
              icon: const Icon(Icons.check_circle_outline),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
