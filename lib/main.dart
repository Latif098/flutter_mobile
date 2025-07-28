import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/pages/splash_screen.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/pages/home_page.dart';
import 'package:tugasakhir_mobile/pages/admin_dashboard.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopLine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InitialScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    // Always show splash screen first
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
