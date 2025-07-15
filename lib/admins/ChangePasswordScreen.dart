import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  bool _isPasswordVisibleOld = false;
  bool _isPasswordVisibleNew = false;
  bool _isPasswordVisibleConfirm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPasswordVisible = false,
    void Function()? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText && !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF008170)),
        suffixIcon:
            obscureText
                ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: toggleVisibility,
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF008170), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _showSuccessPopup() async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: offsetAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Kata sandi berhasil diperbarui',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    }
  }

  Future<void> _reauthenticateAndChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await _showSuccessPopup();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF008170);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi'),
        backgroundColor: mainColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perbarui kata sandi Anda',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Silakan masukkan data di bawah ini untuk mengganti kata sandi.',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),

              _buildInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Masukkan email'
                            : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _oldPasswordController,
                label: 'Kata Sandi Lama',
                icon: Icons.lock_outline,
                obscureText: true,
                isPasswordVisible: _isPasswordVisibleOld,
                toggleVisibility: () {
                  setState(() {
                    _isPasswordVisibleOld = !_isPasswordVisibleOld;
                  });
                },
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Masukkan kata sandi lama'
                            : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _newPasswordController,
                label: 'Kata Sandi Baru',
                icon: Icons.lock,
                obscureText: true,
                isPasswordVisible: _isPasswordVisibleNew,
                toggleVisibility: () {
                  setState(() {
                    _isPasswordVisibleNew = !_isPasswordVisibleNew;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan kata sandi baru';
                  }
                  if (value.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Kata Sandi Baru',
                icon: Icons.lock,
                obscureText: true,
                isPasswordVisible: _isPasswordVisibleConfirm,
                toggleVisibility: () {
                  setState(() {
                    _isPasswordVisibleConfirm = !_isPasswordVisibleConfirm;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ulangi kata sandi baru';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Kata sandi tidak sama';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _reauthenticateAndChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    shadowColor: mainColor.withOpacity(0.4),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
