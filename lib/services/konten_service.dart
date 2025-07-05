import 'package:new_apk/services/konten.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KontenService {
  final supabase = Supabase.instance.client;

  Future<List<Konten>> getNearbyKonten({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) async {
    final response = await supabase.rpc(
      'get_nearby_konten',
      params: {
        'lat_user': latitude,
        'lon_user': longitude,
        'limit_result': limit,
      },
    );

    if (response.error != null) {
      throw Exception('Gagal mengambil data: ${response.error!.message}');
    }

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((item) => Konten.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
