import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _photoUrl;
  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _gender = 'Laki-laki';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user != null) {
      final data =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (data != null) {
        setState(() {
          _nameController.text = data['nama'] ?? '';
          _dobController.text = data['tanggal_lahir'] ?? '';
          _phoneController.text = data['nomor_telepon'] ?? '';
          _gender = data['jenis_kelamin'] ?? 'Laki-laki';
          _photoUrl = data['foto_url'];
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'nama': _nameController.text,
        'tanggal_lahir': _dobController.text,
        'jenis_kelamin': _gender,
        'nomor_telepon': _phoneController.text,
        'foto_url': _photoUrl,
      });

      if (mounted) {
        _showTopModal('Profil berhasil diperbarui');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final bytes = await pickedFile.readAsBytes();
        final fileName =
            '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('profile')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );

        final imageUrl = supabase.storage
            .from('profile')
            .getPublicUrl(fileName);

        await supabase
            .from('profiles')
            .update({'foto_url': imageUrl})
            .eq('id', user.id);

        setState(() {
          _photoUrl = imageUrl;
        });

        _showTopModal('Foto profil berhasil diperbarui');
      }
    }
  }

  void _showTopModal(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 50),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim),
          child: child,
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                          border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                          image:
                              _photoUrl != null
                                  ? DecorationImage(
                                    image: NetworkImage(_photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            _photoUrl == null
                                ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _dobController.text =
                              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: const [
                        DropdownMenuItem(
                          value: 'Laki-laki',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem(
                          value: 'Perempuan',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _gender = value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
