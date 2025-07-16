import 'dart:async';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimationText;
  late Animation<double> _fadeAnimationText;

  final List<Map<String, String>> introData = [
    {
      'image': 'assets/images/center.jpg',
      'title': 'Selamat Datang',
      'desc':
          'Hai traveler kece! Yuk, main ke Indramayu bareng kami, nikmati wisata religi yang keren banget dan bikin hati adem. Gaskeun!',
    },
    {
      'image': 'assets/images/kota.png',
      'title': 'Wisata Religi',
      'desc':
          'Yuk, temukan wisata religi paling keren di Indramayu yang super direkomendasiin buat kamu!',
    },
    {
      'image': 'assets/images/agung.png',
      'title': 'Nikmati Perjalanan',
      'desc':
          'Kira-kira, kejutan seru apa ya yang nungguin kamu di Indramayu? Yuk, cari tahu!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAutoSlide();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimationText = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _fadeAnimationText = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      int nextPage = (_currentPage + 1) % introData.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _animController.reset();
    _animController.forward();
    _startAutoSlide();
  }

  void _nextPage() {
    if (_currentPage < introData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildPage(Map<String, String> data) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(data['image']!, fit: BoxFit.cover),
            ),
          ),
        ),

        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 500, 
          left: 20,
          right: 20,
          child: SlideTransition(
            position: _slideAnimationText,
            child: FadeTransition(
              opacity: _fadeAnimationText,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['desc']!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 4,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: introData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) => _buildPage(introData[index]),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(introData.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? Colors.white
                                : Colors.white54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.blueAccent.withOpacity(0.8),
                  ),
                  child: Text(
                    _currentPage == introData.length - 1 ? 'Mulai' : 'Lanjut',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
