import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_apk/locations/map_picker_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

// asumsi kamu sudah punya MapPickerScreen yg akan mengembalikan { 'lat': .., 'lng': .. }

class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({super.key});

  @override
  State<ManageDestinationsScreen> createState() =>
      _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> destinations = [];
  String searchQuery = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    setState(() => isLoading = true);
    final response = await supabase
        .from('konten')
        .select('*')
        .order('created_at', ascending: false);
    setState(() {
      destinations = response;
      isLoading = false;
    });
  }

  Future<void> _addDestination() async {
    final _judulController = TextEditingController();
    final _descController = TextEditingController();
    final _lokasiController = TextEditingController();
    File? _selectedImage;
    double? selectedLat;
    double? selectedLng;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> _pickImage() async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setModalState(() {
                    _selectedImage = File(pickedFile.path);
                  });
                }
              }

              Future<void> _save() async {
                if (_judulController.text.isEmpty ||
                    _descController.text.isEmpty ||
                    _lokasiController.text.isEmpty ||
                    _selectedImage == null ||
                    selectedLat == null ||
                    selectedLng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                final fileName =
                    '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_selectedImage!.path)}';
                final fileBytes = await _selectedImage!.readAsBytes();
                final contentType = lookupMimeType(_selectedImage!.path);

                await supabase.storage
                    .from('konten')
                    .uploadBinary(
                      fileName,
                      fileBytes,
                      fileOptions: FileOptions(contentType: contentType),
                    );

                final publicUrl = supabase.storage
                    .from('konten')
                    .getPublicUrl(fileName);

                await supabase.from('konten').insert({
                  'judul': _judulController.text,
                  'deskripsi': _descController.text,
                  'gambar_url': publicUrl,
                  'lokasi': _lokasiController.text,
                  'latitude': selectedLat,
                  'longitude': selectedLng,
                });

                Navigator.pop(context);
                _fetchDestinations();
                Flushbar(
                  margin: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  backgroundColor: Colors.green.withOpacity(0.7),
                  boxShadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  messageText: const Text(
                    'Destinasi berhasil disimpan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  duration: const Duration(seconds: 3),
                  flushbarPosition: FlushbarPosition.TOP,
                  animationDuration: const Duration(milliseconds: 500),
                ).show(context);
              }

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 5,
                        width: 50,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        'Tambah Destinasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _judulController,
                        decoration: InputDecoration(
                          labelText: 'Nama Destinasi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lokasiController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Lokasi (koordinat)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.teal, Colors.greenAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPickerScreen(),
                                ),
                              );
                              if (result != null) {
                                setModalState(() {
                                  selectedLat = result['lat'];
                                  selectedLng = result['lng'];
                                  _lokasiController.text =
                                      'Lat: ${selectedLat!.toStringAsFixed(5)}, Lng: ${selectedLng!.toStringAsFixed(5)}';
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Pilih Lokasi di Peta',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              _selectedImage != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          size: 36,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Pilih Gambar di Galeri'),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008170),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text('Simpan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> _deleteDestination(dynamic dest) async {
    setState(() => isLoading = true);
    try {
      await supabase.from('konten').delete().eq('id', dest['id']);
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: Colors.green.withOpacity(0.7),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
        messageText: const Text(
          'Destinasi berhasil dihapus',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        animationDuration: const Duration(milliseconds: 500),
      ).show(context);
      await _fetchDestinations(); // ambil data terbaru
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        destinations.where((dest) {
          final name = (dest['judul'] ?? '').toLowerCase();
          return name.contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Destinasi'),
        backgroundColor: const Color(0xFF008170),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari destinasi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? const Center(child: Text('Tidak ada destinasi ditemukan'))
                    : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final dest = filtered[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                dest['gambar_url'] ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (ctx, e, s) => const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                    ),
                              ),
                            ),
                            title: Text(
                              dest['judul'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(dest['deskripsi'] ?? ''),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'delete') _deleteDestination(dest);
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Hapus'),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDestination,
        backgroundColor: const Color(0xFF008170),
        child: const Icon(Icons.add),
      ),
    );
  }
}
