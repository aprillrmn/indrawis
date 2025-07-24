import 'package:intl/intl.dart';

class CommentModel {
  final String id;
  final String nama;
  final String isi;
  final DateTime tanggal;
  final String foto;
  final String? parentId;
  List<CommentModel> children; // untuk threaded reply

  CommentModel({
    required this.id,
    required this.nama,
    required this.isi,
    required this.tanggal,
    required this.foto,
    this.parentId,
    this.children = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String raw = json['tanggal'] as String;
    String withoutOffset;
    if (raw.contains('+')) {
      withoutOffset = raw.substring(0, raw.indexOf('+'));
    } else if (raw.contains('-') && raw.lastIndexOf('-') > 10) {
      withoutOffset = raw.substring(0, raw.lastIndexOf('-'));
    } else {
      withoutOffset = raw;
    }
    withoutOffset = withoutOffset.replaceFirst(' ', 'T');
    final parsed = DateTime.parse(withoutOffset);

    return CommentModel(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      isi: json['isi'] ?? '',
      tanggal: parsed,
      foto: json['foto'] ?? '',
    );
  }

  String get formattedTanggal {
    final raw = tanggal;
    final display = DateTime(
      raw.year,
      raw.month,
      raw.day,
      raw.hour,
      raw.minute,
      raw.second,
    );
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(display);
  }
}
