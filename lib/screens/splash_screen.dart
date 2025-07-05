import 'package:flutter/material.dart';
import 'dart:async';
import 'package:new_apk/services/auth_service.dart'; // import AuthService

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _checkSession();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  void _checkSession() async {
    final session = await _authService.getSavedSession();
    final role = session != null ? session['role'] : null;

    if (role != null) {
      // Jika ada role berarti sudah login, langsung navigate
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } else {
      // Jika belum login, tunggu 5 detik ke login
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1500),
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
