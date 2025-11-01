import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projek_akhir_mobile/models/konversi_model.dart';
import 'package:projek_akhir_mobile/services/konversi_network.dart';
import 'package:projek_akhir_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BerlangananScreen extends StatefulWidget {
  const BerlangananScreen({super.key});

  @override
  State<BerlangananScreen> createState() => _BerlangananScreenState();
}

class _BerlangananScreenState extends State<BerlangananScreen> {
  final _hartaController = TextEditingController();
  final _currencyService = CurrencyService();
  final NotificationService _notificationService = NotificationService();
  final Color _primaryColor = const Color(0xFF044C9C);
  
  bool _isLoading = true;
  String _error = '';
  final double _nisabIdr = 85000000.0;

  double _nisabUsd = 0.0;
  double _nisabEur = 0.0;
  double _nisabJpy = 0.0;

  String _hasilZakat = '';

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    cekSession();
    _fetchNisabKonversi();
  }

  Future<void> cekSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');
    String? username = prefs.getString('username');

    if (sessionToken == null || username == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _fetchNisabKonversi() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final ApiResponse result = await _currencyService.fetchCurrencyRates();
      final rates = result.data.rates;

      final double? rateUsd = rates['USD']?.value;
      final double? rateEur = rates['EUR']?.value;
      final double? rateJpy = rates['JPY']?.value;

      if (rateUsd == null || rateEur == null || rateJpy == null) {
        throw Exception('Rate mata uang (USD/EUR/JPY) tidak ditemukan');
      }

      setState(() {
        _nisabUsd = _nisabIdr * rateUsd;
        _nisabEur = _nisabIdr * rateEur;
        _nisabJpy = _nisabIdr * rateJpy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data kurs: $e';
      });
    }
  }

  void _hitungZakat() {
    final double? harta = double.tryParse(_hartaController.text);
    String hasil = '';
    double zakat = 0;

    if (harta == null) {
      hasil = 'Masukkan jumlah harta Anda';
    } else if (harta < _nisabIdr) {
      hasil = 'Harta Anda belum mencapai nisab (Rp ${formatter.format(_nisabIdr)}). Anda belum wajib membayar zakat mal.';
    } else {
      zakat = harta * 0.025; 
      hasil = 'Anda wajib membayar zakat mal sebesar:\nRp ${formatter.format(zakat)}';
    }

    setState(() {
      _hasilZakat = hasil;
    });

    if (zakat > 0) {
      _notificationService.showNotification(
        id: 10,
        title: 'Perhitungan Zakat Selesai',
        body: 'Zakat mal Anda adalah Rp ${formatter.format(zakat)}.',
        payload: 'zakat_result',
      );
    }
  }

  @override
  void dispose() {
    _hartaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Kalkulator Zakat Mal"), 
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _buildKalkulator(Theme.of(context)),
    );
  }

  Widget _buildKalkulator(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Informasi Nisab (Batas Wajib Zakat)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nisab zakat mal setara 85 gram emas. Berikut adalah nilai konversinya (asumsi 85gr emas = Rp ${formatter.format(_nisabIdr)}):",
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoNisab(
                    'IDR (Rupiah)',
                    'Rp ${formatter.format(_nisabIdr)}',
                    Icons.wallet_rounded,
                  ),
                  _buildInfoNisab(
                    'USD (Dolar AS)',
                    '\$ ${formatter.format(_nisabUsd)}',
                    Icons.attach_money_rounded,
                  ),
                  _buildInfoNisab(
                    'EUR (Euro)',
                    '€ ${formatter.format(_nisabEur)}',
                    Icons.euro_rounded,
                  ),
                  _buildInfoNisab(
                    'JPY (Yen Jepang)',
                    '¥ ${formatter.format(_nisabJpy)}',
                    Icons.currency_yen_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hitung Zakat Anda",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hartaController,
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      labelText: "Total Harta (Tabungan, Emas, dll) dalam IDR",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _hitungZakat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: const Text(
                        "Hitung Zakat",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_hasilZakat.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: _primaryColor.withOpacity(0.1),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _hasilZakat,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoNisab(String mataUang, String nilai, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor, size: 30),
      title: Text(mataUang, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(
        nilai,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}