class AyatRandomModel {
  final String teks;
  final String namaSurat;
  final int nomorAyat;

  AyatRandomModel({
    required this.teks,
    required this.namaSurat,
    required this.nomorAyat,
  });

  factory AyatRandomModel.fromJson(Map<String, dynamic> json) {
    return AyatRandomModel(
      teks: json['data']['text'] ?? 'Gagal memuat ayat',
      namaSurat: json['data']['surah']['englishName'] ?? 'Unknown',
      nomorAyat: json['data']['numberInSurah'] ?? 0,
    );
  }
}