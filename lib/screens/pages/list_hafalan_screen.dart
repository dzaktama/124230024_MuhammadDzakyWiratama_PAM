import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/models/hafalan_model.dart';
import 'package:projek_akhir_mobile/services/hafalan_save.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _HafalanDenganProgres {
  final Hafalan hafalan;
  final String ayatTerakhir;
  final String catatan;

  _HafalanDenganProgres({
    required this.hafalan,
    required this.ayatTerakhir,
    required this.catatan,
  });
}

class ListHafalanScreen extends StatefulWidget {
  const ListHafalanScreen({super.key});

  @override
  State<ListHafalanScreen> createState() => _ListHafalanScreenState();
}

class _ListHafalanScreenState extends State<ListHafalanScreen> {
  late Future<List<_HafalanDenganProgres>> _hafalanListFuture;
  final Color _primaryColor = const Color(0xFF044C9C);

  @override
  void initState() {
    super.initState();
    cekSession();
    _hafalanListFuture = _loadHafalanDanProgres();
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<List<_HafalanDenganProgres>> _loadHafalanDanProgres() async {
    final List<Hafalan> hafalanList = await HafalanSave().getHafalan();
    final prefs = await SharedPreferences.getInstance();
    
    List<_HafalanDenganProgres> listProgres = [];
    
    for (var hafalan in hafalanList) {
      final String ayat = prefs.getString('hafalan_ayat_${hafalan.id}') ?? '-';
      final String catatan = prefs.getString('hafalan_note_${hafalan.id}') ?? 'Belum ada catatan';
      listProgres.add(_HafalanDenganProgres(
        hafalan: hafalan,
        ayatTerakhir: ayat,
        catatan: catatan,
      ));
    }
    return listProgres;
  }

  void _reloadData() {
     setState(() {
      _hafalanListFuture = _loadHafalanDanProgres();
    });
  }

  void hapusData(int id) async {
    final List<Hafalan> hafalanList = await HafalanSave().getHafalan();
    final index = hafalanList.indexWhere((h) => h.id == id);
    if (index == -1) {
      debugPrint('Hafalan tidak ditemukan');
      return;
    }

    hafalanList.removeAt(index);
    final success = await HafalanSave().saveHafalanList(hafalanList);
    
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hafalan_ayat_$id');
      await prefs.remove('hafalan_note_$id');
      
      _reloadData();
      debugPrint('Hafalan dengan id=$id dihapus');
    } else {
      debugPrint('Gagal menghapus hafalan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Semua Hafalan'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<_HafalanDenganProgres>>(
        future: _hafalanListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada hafalan yang disimpan'));
          }

          final hafalanList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: hafalanList.length,
            itemBuilder: (context, index) {
              final item = hafalanList[index];
              final hafalan = item.hafalan;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: _primaryColor.withOpacity(0.1),
                            child: Icon(Icons.menu_book_rounded, color: _primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${hafalan.namaHafalan} (${hafalan.tipeHafalan})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${hafalan.tanggalMulai} s/d ${hafalan.tanggalSelesai}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => hapusData(hafalan.id),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        'Progres Terakhir:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ayat: ${item.ayatTerakhir}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Catatan: ${item.catatan}',
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}