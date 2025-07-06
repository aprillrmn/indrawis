class Konten {
  final String id;
  final String judul;
  final String? deskripsi;
  final String? lokasi;
  final double? latitude;
  final double? longitude;
  final double? distance; 

  Konten({
    required this.id,
    required this.judul,
    this.deskripsi,
    this.lokasi,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory Konten.fromMap(Map<String, dynamic> map) {
    return Konten(
      id: map['id'] as String,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'],
      lokasi: map['lokasi'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      distance: (map['distance'] as num?)?.toDouble(),
    );
  }
}
