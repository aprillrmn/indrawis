import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final authResponse = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw AuthException('User tidak ditemukan.');
    }

    final data =
        await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

    final role =
        data != null && data['role'] != null ? data['role'] as String : 'user';

    return {'user': user, 'role': role};
  }

  Future<void> saveUserSession(String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  Future<void> resendConfirmationEmail(String email, String password) async {
    await supabase.auth.signUp(email: email, password: password);
  }

  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final role = prefs.getString('role');

    print("DEBUG -> prefs: email=$email, role=$role");

    if (email != null && role != null) {
      return {'email': email, 'role': role};
    }
    return null;
  }

  Future<void> logout() async {
    await supabase.auth.signOut(); // logout dari Supabase
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // hapus semua data local
    print("DEBUG -> Logout selesai, session dihapus.");
  }

  getSavedRole() {}
}
