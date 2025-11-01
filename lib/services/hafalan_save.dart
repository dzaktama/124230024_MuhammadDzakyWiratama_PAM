import 'dart:convert';
import 'package:projek_akhir_mobile/models/hafalan_model.dart';
import 'package:projek_akhir_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HafalanSave {
  final NotificationService _notificationService = NotificationService();

  static String? get hafalanKey => null;

  Future<String> _getDynamicKey() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) {
      return 'hafalan_list_default';
    }
    return 'hafalan_list_$username';
  }

  Future<bool> saveHafalanList(List<Hafalan> hafalanList) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getDynamicKey();
    final hafalanJson = hafalanList.map((e) => jsonEncode(e.toJson())).toList();
    return await prefs.setStringList(key, hafalanJson);
  }

  Future<List<Hafalan>> getHafalanHariIni() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<Hafalan> hafalanList = await getHafalan();
    return hafalanList
        .where(
          (element) =>
              DateTime.parse(element.tanggalMulai).isAtSameMomentAs(today) ||
              (DateTime.parse(element.tanggalMulai).isBefore(today) &&
                  DateTime.parse(element.tanggalSelesai).isAfter(today)),
        )
        .toList();
  }

  Future<List<Hafalan>> getHafalanBesok() async {
    final DateTime now = DateTime.now();
    final DateTime besok = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final List<Hafalan> hafalanList = await getHafalan();
    return hafalanList.where((element) {
      final tanggalMulai = DateTime.parse(element.tanggalMulai);
      final tanggalSelesai = DateTime.parse(element.tanggalSelesai);
      return tanggalMulai.isAtSameMomentAs(besok) ||
          (tanggalMulai.isBefore(besok) && tanggalSelesai.isAfter(besok));
    }).toList();
  }

  Future<List<Hafalan>> getHafalan() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getDynamicKey();
    final List<String> hafalanJson = prefs.getStringList(key) ?? [];
    return hafalanJson.map((e) => Hafalan.fromJson(jsonDecode(e))).toList();
  }

  Future<bool> addHafalan(Hafalan newHafalan) async {
    final List<Hafalan> currentList = await getHafalan();
    currentList.add(newHafalan);

    await _notificationService.showNotification(
      id: 0,
      title: 'Hafalan baru nih!',
      body:
          'Bismillahirrahmanirrahim, semangat memulai hafalan ${newHafalan.namaHafalan}!',
      payload: 'data tambahan',
    );

    return await saveHafalanList(currentList);
  }

  Future<bool> adaHafalanBelumSelesai() async {
    final List<Hafalan> allHafalan = await getHafalan();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    for (var hafalan in allHafalan) {
      DateTime mulai = DateTime.parse(hafalan.tanggalMulai);
      DateTime selesai = DateTime.parse(hafalan.tanggalSelesai);

      if ((mulai.isBefore(today) || mulai.isAtSameMomentAs(today)) &&
          (selesai.isAfter(today) || selesai.isAtSameMomentAs(today))) {
        return true;
      }
    }
    return false;
  }
}
