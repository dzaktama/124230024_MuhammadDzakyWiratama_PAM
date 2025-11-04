import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projek_akhir_mobile/models/konversi_model.dart';
import 'package:projek_akhir_mobile/services/konversi_network.dart';
import 'package:projek_akhir_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class kalkulatorScreen extends StatefulWidget {
  const kalkulatorScreen({super.key});

  @override
  State<kalkulatorScreen> createState() => _kalkulatorScreenState();
}

class _kalkulatorScreenState extends State<kalkulatorScreen> {
  final _hartaController = TextEditingController();
  final _currencyService = CurrencyService();
  final NotificationService _notificationService = NotificationService();
  final Color _primaryColor = const Color(0xFF044C9C);
  
  bool _isLoading = true;
  String _error = '';
  final double _nisabIdr = 85000000.0;

  double _rateUsd = 0.0;
  double _rateEur = 0.0;
  double _rateJpy = 0.0;
  double _rateSar = 0.0;
  
  String _mataUangInput = "IDR";
  String _hasilZakat = '';

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  final formatterAsing = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
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
      final double? rateSar = rates['SAR']?.value;

      if (rateUsd == null || rateEur == null || rateJpy == null || rateSar == null) {
        throw Exception('Rate mata uang (USD/EUR/JPY/SAR) tidak ditemukan');
      }

      setState(() {
        _rateUsd = rateUsd;
        _rateEur = rateEur;
        _rateJpy = rateJpy;
        _rateSar = rateSar;
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
    double zakatFinal = 0;
    double hartaInIDR = 0;
    String simbolMataUang = 'Rp ';
    String notifBody = '';
    
    double nisabUsd = _nisabIdr * _rateUsd;
    double nisabEur = _nisabIdr * _rateEur;
    double nisabJpy = _nisabIdr * _rateJpy;
    double nisabSar = _nisabIdr * _rateSar;

    if (harta == null) {
      hasil = 'Masukkan jumlah harta Anda';
    } else {
      String nisabFormatted = '';

      if (_mataUangInput == 'USD') {
        hartaInIDR = harta / _rateUsd;
        simbolMataUang = '\$ ';
        nisabFormatted = '\$ ${formatterAsing.format(nisabUsd)}';
      } else if (_mataUangInput == 'EUR') {
        hartaInIDR = harta / _rateEur;
        simbolMataUang = '€ ';
        nisabFormatted = '€ ${formatterAsing.format(nisabEur)}';
      } else if (_mataUangInput == 'JPY') {
        hartaInIDR = harta / _rateJpy;
        simbolMataUang = '¥ ';
        nisabFormatted = '¥ ${formatterAsing.format(nisabJpy)}';
      } else if (_mataUangInput == 'SAR') {
        hartaInIDR = harta / _rateSar;
        simbolMataUang = 'SAR ';
        nisabFormatted = 'SAR ${formatterAsing.format(nisabSar)}';
      } else {
        hartaInIDR = harta;
        nisabFormatted = formatter.format(_nisabIdr);
      }

      if (hartaInIDR < _nisabIdr) {
        hasil = 'Harta Anda belum mencapai nisab ($nisabFormatted). Anda belum wajib membayar zakat mal.';
      } else {
        zakatFinal = harta * 0.025; 
        
        if (_mataUangInput == 'IDR') {
           hasil = 'Anda wajib membayar zakat mal sebesar:\n${formatter.format(zakatFinal)}';
           notifBody = 'Zakat mal Anda adalah ${formatter.format(zakatFinal)}.';
        } else {
           hasil = 'Anda wajib membayar zakat mal sebesar:\n$simbolMataUang${formatterAsing.format(zakatFinal)}';
           double zakatInIDR = hartaInIDR * 0.025;
           notifBody = 'Zakat mal Anda adalah $simbolMataUang${formatterAsing.format(zakatFinal)} (Setara ${formatter.format(zakatInIDR)})';
        }
      }
    }

    setState(() {
      _hasilZakat = hasil;
    });

    if (zakatFinal > 0) {
      _notificationService.showNotification(
        id: 10,
        title: 'Perhitungan Zakat Selesai',
        body: notifBody,
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
    final theme = Theme.of(context);
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
              : _buildKalkulator(theme),
    );
  }

  Widget _buildKalkulator(ThemeData theme) {
    double nisabUsd = _nisabIdr * _rateUsd;
    double nisabEur = _nisabIdr * _rateEur;
    double nisabJpy = _nisabIdr * _rateJpy;
    double nisabSar = _nisabIdr * _rateSar;

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
                    "Nisab zakat mal setara 85 gram emas. Berikut adalah nilai konversinya (asumsi 85gr emas = ${formatter.format(_nisabIdr)}):",
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoNisab(
                    'IDR (Rupiah)',
                    formatter.format(_nisabIdr),
                    Icons.wallet_rounded,
                  ),
                  _buildInfoNisab(
                    'USD (Dolar AS)',
                    '\$ ${formatterAsing.format(nisabUsd)}',
                    Icons.attach_money_rounded,
                  ),
                  _buildInfoNisab(
                    'EUR (Euro)',
                    '€ ${formatterAsing.format(nisabEur)}',
                    Icons.euro_rounded,
                  ),
                  _buildInfoNisab(
                    'JPY (Yen Jepang)',
                    '¥ ${formatterAsing.format(nisabJpy)}',
                    Icons.currency_yen_rounded,
                  ),
                  _buildInfoNisab(
                    'SAR (Riyal Saudi)',
                    'SAR ${formatterAsing.format(nisabSar)}',
                    Icons.account_balance_wallet_outlined,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _hartaController,
                          decoration: InputDecoration(
                            labelText: "Total Harta",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _mataUangInput,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          items: <String>['IDR', 'USD', 'EUR', 'JPY', 'SAR']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _mataUangInput = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
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