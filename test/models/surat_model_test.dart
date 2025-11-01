import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/surat_model.dart';

void main() {
  group('Surat', () {
    test('should create a Surat object with complete data', () {
      final surat = Surat(
        nomor: 1,
        nama: "الفاتحة",
        namaLatin: "Al-Fatihah",
        jumlahAyat: 7,
        arti: "Pembukaan",
      );

      expect(surat.nomor, 1);
      expect(surat.nama, "الفاتحة");
      expect(surat.namaLatin, "Al-Fatihah");
      expect(surat.jumlahAyat, 7);
      expect(surat.arti, "Pembukaan");
    });

    test('fromApiJson should correctly parse complete API JSON', () {
      final Map<String, dynamic> json = {
        'number': 1,
        'name': "الفاتحة",
        'englishName': "Al-Fatihah",
        'numberOfAyahs': 7,
        'englishNameTranslation': "Pembukaan",
      };

      final surat = Surat.fromApiJson(json);

      expect(surat.nomor, 1);
      expect(surat.nama, "الفاتحة");
      expect(surat.namaLatin, "Al-Fatihah");
      expect(surat.jumlahAyat, 7);
      expect(surat.arti, "Pembukaan");
    });

    test('fromApiJson should handle missing or null data with default values', () {
      final Map<String, dynamic> json = {
        'number': null,
        'englishName': "Al-Fatihah",
        'numberOfAyahs': null,
      };

      final surat = Surat.fromApiJson(json);

      expect(surat.nomor, 0);
      expect(surat.nama, 'noData');
      expect(surat.namaLatin, "Al-Fatihah");
      expect(surat.jumlahAyat, 0);
      expect(surat.arti, 'noData');
    });
  });
}