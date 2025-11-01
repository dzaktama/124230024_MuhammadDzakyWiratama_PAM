// lib/models/lokasi_model.dart

// ini model data buat nyimpen catatan lokasi
class LokasiModel {
  final int id;
  final String waktuCatat; // disimpan dalam format ISO string
  final double latitude;
  final double longitude;
  final String alamat;

  LokasiModel({
    required this.id,
    required this.waktuCatat,
    required this.latitude,
    required this.longitude, // koma ditambahkan di sini
    required this.alamat,
  });

  // ubah dari json (map) ke object LokasiModel
  factory LokasiModel.fromJson(Map<String, dynamic> json) => LokasiModel(
        id: json['id'] ?? 0,
        waktuCatat: json['waktuCatat'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        alamat: json['alamat'] ?? 'Alamat tidak ditemukan',
      );

  // ubah dari object LokasiModel ke json (map)
  Map<String, dynamic> toJson() => {
        'id': id,
        'waktuCatat': waktuCatat,
        'latitude': latitude,
        'longitude': longitude,
        'alamat': alamat,
      };
}