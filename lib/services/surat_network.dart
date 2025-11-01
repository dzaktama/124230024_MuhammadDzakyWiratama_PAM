import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir_mobile/models/surat_model.dart';
import 'package:projek_akhir_mobile/models/surat_detail_model.dart';
import 'package:projek_akhir_mobile/models/ayat_random_model.dart';

class SuratNetwork {
  final String baseUrl = 'https://api.alquran.cloud/v1';

  Future<AyatRandomModel?> getAyatRandom() async {
    final uri = Uri.parse('$baseUrl/ayah/random/id.indonesian');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return AyatRandomModel.fromJson(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Surat>> getData() async {
    final uri = Uri.parse('$baseUrl/surah');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map<Surat>((item) {
          return Surat.fromApiJson(item);
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<SuratDetail?> getDetailSurah(int nomor) async {
    final uri = Uri.parse('$baseUrl/surah/$nomor/editions/quran-uthmani,id.indonesian');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final data = body['data'];
        if (data != null) {
          return SuratDetail.fromApiJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<SuratDetail?> getDetailData(int nomor) async {
    return await getDetailSurah(nomor);
  }

  Future<List<Surat>> searchSurat(String query) async {
    final all = await getData();
    final q = query.toLowerCase();
    return all.where((s) {
      return s.nama.toLowerCase().contains(q) ||
          s.namaLatin.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<Surat>> sortDescSurat() async {
    final data = await getData();
    return data.reversed.toList();
  }
}