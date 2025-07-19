import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_apk/locations/map_picker_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:another_flushbar/flushbar.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();
  bool loading = false;
  List<Map<String, dynamic>> categories = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => loading = true);
    try {
      final data = await supabase.from('kategori').select();
      setState(() {
        categories =
            (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      _showError('Gagal memuat kategori: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    return categories
        .where(
          (cat) =>
              cat['nama']?.toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
              false,
        )
        .toList();
  }

  void _showError(String msg) {
    Flushbar(
      message: msg,
      backgroundColor: Colors.red[600]!,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    ).show(context);
  }

  void _showTopSuccess(String msg) {
    Flushbar(
      message: msg,
      backgroundColor: Colors.green[600]!,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    ).show(context);
  }

  Future<void> _showAddModal() async {
    final formKey = GlobalKey<FormState>();
    String name = '', desc = '';
    File? imageFile;
    double? lat, lng;
    int kategoriGrupId = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                return Form(
                  key: formKey,
                  child: Wrap(
                    runSpacing: 12,
                    children: [
                      Text(
                        'Tambah Kategori',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nama Kategori',
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Nama wajib diisi'
                                    : null,
                        onSaved: (v) => name = v!.trim(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                        ),
                        onSaved: (v) => desc = v?.trim() ?? '',
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Kategori Grup ID',
                        ),
                        value: kategoriGrupId == 0 ? null : kategoriGrupId,
                        items:
                            [1, 2, 3, 4].map((id) {
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text('Grup $id'),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              kategoriGrupId = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) return 'Pilih salah satu grup';
                          return null;
                        },
                        onSaved: (value) {
                          kategoriGrupId = value ?? 0;
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          final file = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setModalState(() => imageFile = File(file.path));
                          }
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child:
                                imageFile != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        imageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                    : const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Pilih Gambar'),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await Navigator.push<Map<String, double>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MapPickerScreen(),
                                ),
                              );
                          if (result != null) {
                            setModalState(() {
                              lat = result['lat'];
                              lng = result['lng'];
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.shade700),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.map, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text(
                                lat != null
                                    ? 'Lokasi: ${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                                    : 'Pilih Lokasi',
                                style: TextStyle(
                                  color:
                                      lat != null
                                          ? Colors.black87
                                          : Colors.teal[800],
                                  fontWeight:
                                      lat != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate() ||
                                lat == null ||
                                lng == null) {
                              _showError('Form belum lengkap');
                              return;
                            }
                            formKey.currentState!.save();
                            Navigator.pop(context);
                            setState(() => loading = true);
                            try {
                              String? imageUrl;
                              if (imageFile != null) {
                                final fileName =
                                    '${DateTime.now().millisecondsSinceEpoch}_${imageFile!.path.split('/').last}';
                                Uint8List bytes =
                                    await imageFile!.readAsBytes();
                                await supabase.storage
                                    .from('kategori')
                                    .uploadBinary('kategori/$fileName', bytes);
                                imageUrl = supabase.storage
                                    .from('kategori')
                                    .getPublicUrl('kategori/$fileName');
                              }
                              await supabase.from('kategori').insert({
                                'nama': name,
                                'deskripsi': desc,
                                'gambar_url': imageUrl,
                                'latitude': lat,
                                'longitude': lng,
                                'kategori_grup_id': kategoriGrupId,
                              });
                              _showTopSuccess('Kategori berhasil ditambahkan');
                              await _loadCategories();
                            } catch (e) {
                              _showError('Gagal menyimpan: $e');
                            } finally {
                              setState(() => loading = false);
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kelola Kategori',
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
          loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                    child: RefreshIndicator(
                      onRefresh: _loadCategories,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredCategories.length,
                        itemBuilder: (_, i) {
                          final cat = filteredCategories[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading:
                                  cat['gambar_url'] != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          cat['gambar_url'],
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.category,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                              title: Text(
                                cat['nama'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                cat['deskripsi'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text(
                                            'Hapus kategori ini?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, false),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm != true) return;
                                  setState(() => loading = true);
                                  try {
                                    await supabase
                                        .from('kategori')
                                        .delete()
                                        .eq('id', cat['id']);
                                    _showTopSuccess('Kategori dihapus');
                                    await _loadCategories();
                                  } catch (e) {
                                    _showError('Gagal menghapus: $e');
                                  } finally {
                                    setState(() => loading = false);
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        onPressed: _showAddModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
