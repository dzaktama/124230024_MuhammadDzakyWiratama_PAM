// lib/services/lokasi_service.dart

import 'dart:convert';
import 'package:projek_akhir_mobile/models/lokasi_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as geo; // Impor eksplisit

// kelas ini ngurusin semua soal simpan, ambil, dan proses data lokasi
class LokasiService {
  static const String _lokasiKey = 'lokasi_list';

  // fungsi buat simpan list lokasi
  Future<bool> _saveLokasiList(List<LokasiModel> lokasiList) async {
    final prefs = await SharedPreferences.getInstance();
    // PERBAIKAN: Mengganti Tson() menjadi toJson()
    final lokasiJson =
        lokasiList.map((e) => jsonEncode(e.toJson())).toList(); 
        
    return await prefs.setStringList(_lokasiKey, lokasiJson);
  }

  // fungsi buat ambil semua list lokasi
  Future<List<LokasiModel>> getSemuaLokasi() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> lokasiJson = prefs.getStringList(_lokasiKey) ?? [];
    
    return lokasiJson
        // PERBAIKAN: Mengganti Tson() menjadi toJson() di model
        .map((e) => LokasiModel.fromJson(jsonDecode(e))) 
        .toList();
  }

  // fungsi buat nambah satu catatan lokasi baru
  Future<bool> simpanLokasi(LokasiModel lokasiBaru) async {
    final List<LokasiModel> currentList = await getSemuaLokasi();
    currentList.add(lokasiBaru);
    
    return await _saveLokasiList(currentList);
  }

  // fungsi buat ubah koordinat (lat, lon) jadi alamat jalan
  Future<String> getAlamatFromKoordinat(
      double latitude,
      double longitude,) async {
    try {
      // Panggil fungsi placemarkFromCoordinates menggunakan prefix 'geo'
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final geo.Placemark p = placemarks[0];
        // hasil: "Nama Jalan, Kota, Negara"
        return "${p.street}, ${p.subLocality}, ${p.locality}, ${p.country}";
      } else {
        return "Alamat tidak ditemukan";
      }
    } catch (e) {
      // kasih pesan error yang lebih jelas di konsol
      print("Geocoding Error: $e");
      return "Error: Gagal mendapatkan alamat";
    }
  }
}