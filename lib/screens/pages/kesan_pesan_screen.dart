import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KesanTpmScreen extends StatefulWidget {
  const KesanTpmScreen({super.key});

  @override
  State<KesanTpmScreen> createState() => _KesanTpmScreenState();
}

class _KesanTpmScreenState extends State<KesanTpmScreen> {
  final Color _primaryColor = const Color(0xFF044C9C);
  final TextEditingController _kesanController = TextEditingController();
  List<String> _daftarKesan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    cekSession();
    _loadKesan();
  }

  @override
  void dispose() {
    _kesanController.dispose();
    super.dispose();
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _loadKesan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _daftarKesan = prefs.getStringList('daftar_kesan_pribadi') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _submitKesan() async {
    if (_kesanController.text.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> pesanBaru = List.from(_daftarKesan);
    pesanBaru.add(_kesanController.text);

    await prefs.setStringList('daftar_kesan_pribadi', pesanBaru);

    setState(() {
      _daftarKesan = pesanBaru;
    });
    _kesanController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kesan & Pesan'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tambahkan Kesan Pribadi Anda",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _kesanController,
                        decoration: InputDecoration(
                          labelText: 'Tulis kesan Anda di sini...',
                          hintText: 'Misal: Aplikasi ini sangat membantu...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitKesan,
                          icon: const Icon(Icons.send),
                          label: const Text('Kirim'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 8, left: 4),
                child: Text(
                  'Kesan yang Sudah Dikirim',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _daftarKesan.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text("Belum ada kesan pribadi yang ditambahkan."),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _daftarKesan.length,
                          itemBuilder: (context, index) {
                            final pesan = _daftarKesan.reversed.toList()[index]; 
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: Icon(Icons.chat_bubble_outline, color: _primaryColor),
                                title: Text(pesan),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}