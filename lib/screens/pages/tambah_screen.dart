import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek_akhir_mobile/models/hafalan_model.dart';
import 'package:projek_akhir_mobile/services/hafalan_save.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahScreen extends StatefulWidget {
  const TambahScreen({super.key});

  @override
  State<TambahScreen> createState() => _TambahScreenState();
}

class _TambahScreenState extends State<TambahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaSuratController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();
  late int _idDariAPI;
  String? _namaSurat;
  bool _isLoading = false;
  String? _error;
  final Color _primaryColor = const Color(0xFF044C9C);

  @override
  void initState() {
    super.initState();
    cekSession();

    _tanggalMulaiController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _namaSurat == null) {
      _idDariAPI = args['nomor'];
      _namaSurat = args['nama'];
      _namaSuratController.text = _namaSurat.toString();
    }
  }

  @override
  void dispose() {
    _namaSuratController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _pickTanggalSelesai() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_tanggalSelesaiController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _tanggalSelesaiController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(pickedDate);
      setState(() {});
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final hafalanList = await HafalanSave().getHafalan();
      final newId = hafalanList.isNotEmpty ? hafalanList.last.id + 1 : 1;
      Hafalan newHafalan = Hafalan(
        id: newId,
        idHafalan: _idDariAPI, 
        namaHafalan: _namaSuratController.text,
        tipeHafalan: 'surat',
        tanggalMulai: _tanggalMulaiController.text,
        tanggalSelesai: _tanggalSelesaiController.text,
      );

      final success = await HafalanSave().addHafalan(newHafalan);

      if (success && mounted) {
        Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Gagal tambah data';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal tambah data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tambah Hafalan Surat'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: _primaryColor))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Masukkan Detail Hafalan',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _namaSuratController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Nama Surat',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(
                                Icons.menu_book_outlined,
                                color: _primaryColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _tanggalMulaiController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Tanggal Mulai',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: _primaryColor,
                              ),
                              suffixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _tanggalSelesaiController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Tanggal Selesai',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: _primaryColor,
                              ),
                             suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: _primaryColor,
                                ),
                                onPressed: _pickTanggalSelesai,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal selesai wajib diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          if (_error != null) ...[
                            Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submit,
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Simpan Hafalan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}