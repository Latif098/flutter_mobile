import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/pages/home_page.dart';
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "Shopline@gmail.com");
  final _passwordController = TextEditingController(text: "123456");
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _showSuccessPopup = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Starts from bottom
      end: Offset.zero, // Ends at original position
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (result['success']) {
          // Show success popup
          setState(() {
            _isLoading = false;
            _showSuccessPopup = true;
          });
          _animationController.forward();

          // Wait before navigating
          Timer(const Duration(seconds: 3), () {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          });
        } else {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Login gagal')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            // Main login form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // Logo
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D7CDB),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Login with Email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your email dan password',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    // Email field
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      isPassword: false,
                      hasCheckmark: true,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    _buildInputField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      hasCheckmark: false,
                    ),
                    const SizedBox(height: 8),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: const Color(0xFF2D7CDB),
                        ),
                        child: const Text(
                          'Forgot Password ?',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sign in button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D7CDB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Success popup
            if (_showSuccessPopup)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Login Successful!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D7CDB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
    required bool hasCheckmark,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(icon, color: Colors.grey),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword && !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$hintText tidak boleh kosong';
                }
                if (!isPassword &&
                    !RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      padding: EdgeInsets.zero,
                    )
                    : hasCheckmark
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const SizedBox(width: 40),
          ),
        ],
      ),
    );
  }
}
