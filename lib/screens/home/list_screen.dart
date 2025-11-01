import 'package:flutter/material.dart';
import 'package:projek_akhir_mobile/services/surat_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir_mobile/models/surat_model.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _searchController = TextEditingController();
  late Future<List<Surat>> _dataFuture;
  bool _isLoading = false;
  bool _isSorting = false;
  final Color _primaryColor = const Color(0xFF044C9C);

  @override
  void initState() {
    super.initState();
    cekSession();
    _fetchData();
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _fetchData({
    String? searchQuery,
    bool sortDesc = false,
  }) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _dataFuture = SuratNetwork().searchSurat(searchQuery);
      } else if (sortDesc) {
        _dataFuture = SuratNetwork().sortDescSurat();
      } else {
        _dataFuture = SuratNetwork().getData();
      }

      setState(() {
        _isSorting = sortDesc;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data Surat: $e')),
      );
      _dataFuture = Future.value([]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('username');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _buildList(List<Surat> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final surat = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: _primaryColor,
              child: Text(
                surat.nomor.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    surat.namaLatin,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor, 
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  surat.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Artinya: ${surat.arti} | ${surat.jumlahAyat} Ayat',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/tambah',
                arguments: {
                  'nomor': surat.nomor,
                  'nama': surat.namaLatin,
                  'tipe': 'surat',
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Surat Al-Qur'an"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari Surat...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onFieldSubmitted: (value) => _fetchData(
                      searchQuery: value,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    color: _primaryColor,
                    icon: Icon(
                      _isSorting
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                    ),
                    onPressed: () => _fetchData(
                      sortDesc: !_isSorting,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<Surat>>( 
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                    return Center(child: CircularProgressIndicator(color: _primaryColor));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Gagal terhubung ke API Al-Qur\'an. Pastikan internet stabil.\n${snapshot.error.toString()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada data Surat ditemukan.'));
                  }
                  return _buildList(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}