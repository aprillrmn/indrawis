class CommentModel {
  final String id;
  final String nama;
  final String isi;
  final DateTime tanggal;
  final String foto;

  CommentModel({
    required this.id,
    required this.nama,
    required this.isi,
    required this.tanggal,
    required this.foto,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id:
          json['id']
              .toString(), // penting supaya aman jika id bertipe int atau string/uuid
      nama: json['nama'] ?? '',
      isi: json['isi'] ?? '',
      tanggal: DateTime.parse(json['tanggal']),
      foto: json['foto'] ?? '',
    );
  }
}
