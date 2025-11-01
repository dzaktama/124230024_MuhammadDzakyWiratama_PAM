class SuratDetail {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final List<Ayat> ayat;

  SuratDetail({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.ayat,
  });

  factory SuratDetail.fromApiJson(List<dynamic> jsonList) {
    final Map<String, dynamic> dataArab = jsonList[0];
    final Map<String, dynamic> dataIndo = jsonList[1];

    final List<dynamic> ayatsArab = dataArab['ayahs'];
    final List<dynamic> ayatsTerjemahan = dataIndo['ayahs'];

    List<Ayat> ayatsGabungan = [];

    for (int i = 0; i < ayatsArab.length; i++) {
      ayatsGabungan.add(Ayat(
        nomorAyat: ayatsArab[i]['numberInSurah'] ?? 0,
        teksArab: ayatsArab[i]['text'] ?? 'noData',
        teksIndonesia: ayatsTerjemahan[i]['text'] ?? 'noData',
        audio: '',
        teksLatin: 'Latin not available',
      ));
    }

    return SuratDetail(
      nomor: dataArab['number'] ?? 0,
      nama: dataArab['name'] ?? 'noData',
      namaLatin: dataArab['englishName'] ?? 'noData',
      jumlahAyat: dataArab['numberOfAyahs'] ?? 0,
      tempatTurun: dataArab['revelationType'] ?? 'noData',
      arti: dataIndo['englishNameTranslation'] ?? 'noData',
      ayat: ayatsGabungan,
    );
  }
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final String audio; 

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) => Ayat(
        nomorAyat: json['numberInSurah'] ?? 0,
        teksArab: json['text'] ?? 'noData',
        teksLatin: json['teksLatin'] ?? 'noData',
        teksIndonesia: json['teksIndonesia'] ?? 'noData',
        audio: json['audio'] ?? '',
      );
}

class SuratSingkat {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  SuratSingkat({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory SuratSingkat.fromApiJson(Map<String, dynamic> json) => SuratSingkat(
        nomor: json['number'] ?? 0,
        nama: json['name'] ?? 'noData',
        namaLatin: json['englishName'] ?? 'noData',
        jumlahAyat: json['numberOfAyahs'] ?? 0,
      );
}