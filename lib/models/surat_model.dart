class Surat {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String arti;

  Surat({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.arti,
  });

  factory Surat.fromApiJson(Map<String, dynamic> json) {
    return Surat(
      nomor: json['number'] ?? 0,
      nama: json['name'] ?? 'noData',
      namaLatin: json['englishName'] ?? 'noData',
      jumlahAyat: json['numberOfAyahs'] ?? 0,
      arti: json['englishNameTranslation'] ?? 'noData',
    );
  }
}