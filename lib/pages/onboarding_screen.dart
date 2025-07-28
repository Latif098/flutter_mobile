import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _navigateToNext() async {
    // Mark onboarding as completed
    await StorageHelper.setOnboardingCompleted();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Phone mockup
                          Positioned(
                            right: 40,
                            top: 20,
                            child: Container(
                              width: 200,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 2),
                              ),
                              child: Column(
                                children: [
                                  // Phone screen
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        // Header
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            'ShopLine',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),

                                        // Shopping bag image
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.purple[400]!,
                                                  Colors.blue[600]!,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.shopping_bag,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Add to cart button
                                        Container(
                                          margin: const EdgeInsets.all(12),
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'ADD TO CART',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Person illustration
                          Positioned(
                            left: 0,
                            bottom: 60,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: Stack(
                                children: [
                                  // Person avatar
                                  Positioned(
                                    top: 20,
                                    left: 35,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ),
                                  // Person body
                                  Positioned(
                                    bottom: 20,
                                    left: 25,
                                    child: Container(
                                      width: 70,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Shopping elements
                          Positioned(
                            right: 10,
                            bottom: 20,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Welcome to ShopLine',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: const Text(
                        'One Best App For All You Need',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Get Started Button & Loading indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  // Get Started Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading indicator
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
