// kategori_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

Future<List<Map<String, dynamic>>> fetchKategoriByGrupId(
    int kategoriGrupId, Position? userPosition) async {
  final data = await Supabase.instance.client
      .from('kategori')
      .select(
        'id, nama, deskripsi, gambar_url, latitude, longitude, created_at, updated_at, kategori_grup_id',
      )
      .eq('kategori_grup_id', kategoriGrupId);

  final items = List<Map<String, dynamic>>.from(data);

  if (userPosition != null) {
    for (var d in items) {
      d['distance'] = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        (d['latitude'] ?? 0).toDouble(),
        (d['longitude'] ?? 0).toDouble(),
      );
    }

    items.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double));
  }

  return items;
}
