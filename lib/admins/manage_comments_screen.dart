import 'package:flutter/material.dart';
import 'package:new_apk/models/coment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      setState(() {
        commentList =
            (response as List)
                .map((item) => CommentModel.fromJson(item))
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
    final sortedList = [...commentList];
    sortedList.sort(
      (a, b) =>
          _sortTerbaru
              ? b.tanggal.compareTo(a.tanggal)
              : a.tanggal.compareTo(b.tanggal),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kelola Komentar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF008170), Color(0xFF00B686)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : commentList.isEmpty
              ? const Center(child: Text('Belum ada komentar'))
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[300],
                                      image:
                                          komentar.foto.isNotEmpty
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  komentar.foto,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        komentar.foto.isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    komentar.nama,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(komentar.isi),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatTanggal(
                                                      komentar.tanggal,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
    return "${tanggal.day.toString().padLeft(2, '0')}/"
        "${tanggal.month.toString().padLeft(2, '0')}/"
        "${tanggal.year} "
        "${tanggal.hour.toString().padLeft(2, '0')}:"
        "${tanggal.minute.toString().padLeft(2, '0')}";
  }
}
