import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coment_model.dart';

class ManageCommentsScreen extends StatefulWidget {
  const ManageCommentsScreen({super.key});

  @override
  State<ManageCommentsScreen> createState() => _ManageCommentsScreenState();
}

class _ManageCommentsScreenState extends State<ManageCommentsScreen> {
  bool _sortTerbaru = true;
  List<CommentModel> commentList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKomentar();
  }

  Future<void> _fetchKomentar() async {
    try {
      final response = await Supabase.instance.client
          .from('komentar')
          .select()
          .order('tanggal', ascending: false);

      final data = response as List;

      setState(() {
        commentList =
            data
                .map(
                  (item) => CommentModel(
                    id: item['id'].toString(),
                    nama: item['nama'] ?? '',
                    isi: item['isi'] ?? '',
                    tanggal: DateTime.parse(item['tanggal']),
                    foto: item['foto'] ?? '',
                  ),
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error saat fetch komentar: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CommentModel> sortedList = List.from(commentList);
    sortedList.sort(
      (a, b) =>
          _sortTerbaru
              ? b.tanggal.compareTo(a.tanggal)
              : a.tanggal.compareTo(b.tanggal),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar Pengguna'),
        backgroundColor: const Color(0xFF008170),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<bool>(
                          value: _sortTerbaru,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Terbaru'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Terlama'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _sortTerbaru = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedList.length,
                      itemBuilder: (context, index) {
                        final komentar = sortedList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    komentar.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(komentar.isi),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTanggal(komentar.tanggal),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  String _formatTanggal(DateTime tanggal) {
    return "${tanggal.day}/${tanggal.month}/${tanggal.year} ${tanggal.hour}:${tanggal.minute.toString().padLeft(2, '0')}";
  }
}
