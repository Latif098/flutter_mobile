import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:tugasakhir_mobile/pages/onboarding_screen.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/pages/home_page.dart';
import 'package:tugasakhir_mobile/pages/admin_dashboard.dart';
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _checkAppState();
  }

  void _initAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo fade and scale
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    _subtitleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    ));

    // Loading animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _logoController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _loadingController.repeat();
      }
    });
  }

  Future<void> _checkAppState() async {
    // Wait for splash screen display
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // User is logged in, check role and navigate accordingly
        final userJson = await StorageHelper.getUser();
        if (userJson != null) {
          final user = UserModel.fromJson(jsonDecode(userJson));

          // Navigate based on user role
          if (user.roleId == 1) {
            // Admin user
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else {
            // Regular user
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
          return;
        }
      }

      // User not logged in, check onboarding status
      final isOnboardingCompleted = await StorageHelper.isOnboardingCompleted();

      if (isOnboardingCompleted) {
        // Onboarding completed, go directly to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // First time user, show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      print('Error checking app state: $e');
      // On error, show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF357ABD),
              Color(0xFF2E5B99),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shopping_bag,
                                  size: 50,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Animated App Name
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _textFadeAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _textController,
                                curve: const Interval(0.3, 0.7,
                                    curve: Curves.easeOut),
                              )),
                              child: const Text(
                                'ShopLine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Animated Subtitle
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _subtitleFadeAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _textController,
                                curve: const Interval(0.5, 0.9,
                                    curve: Curves.easeOut),
                              )),
                              child: const Text(
                                'One Best App For All You Need',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Animated Loading Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    // Loading text
                    FadeTransition(
                      opacity: _subtitleFadeAnimation,
                      child: const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Animated progress bar
                    Container(
                      width: 150,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Container(
                                width: 150 * _loadingAnimation.value,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white70,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
