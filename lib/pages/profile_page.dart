import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/pages/address_page.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/pages/order_history_page.dart';
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userJson = await StorageHelper.getUser();
      if (userJson != null) {
        setState(() {
          _user = UserModel.fromJson(jsonDecode(userJson));
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Notification functionality
            },
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? _buildNotLoggedIn()
              : _buildAccountMenu(),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'You are not logged in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenu() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // Your Profile
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Your Profile',
          onTap: () {
            // Navigate to profile edit
            _showProfileInfo();
          },
        ),

        // My Order
        _buildMenuItem(
          icon: Icons.receipt_long_outlined,
          title: 'My Order',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
            );
          },
        ),

        // Payment Methods
        _buildMenuItem(
          icon: Icons.credit_card_outlined,
          title: 'Payment Methods',
          onTap: () {
            _showComingSoon('Payment Methods');
          },
        ),

        // Notifications
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {
            _showComingSoon('Notifications');
          },
        ),

        // Privacy Policy
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {
            _showComingSoon('Privacy Policy');
          },
        ),

        // Help Center
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help Center',
          onTap: () {
            _showComingSoon('Help Center');
          },
        ),

        // Invite Friends
        _buildMenuItem(
          icon: Icons.person_add_outlined,
          title: 'Invite Friends',
          onTap: () {
            _showComingSoon('Invite Friends');
          },
        ),

        const SizedBox(height: 20),

        // Log Out
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Log Out',
          onTap: _logout,
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.grey[700],
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  void _showProfileInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Profile header
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _user!.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _user!.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // User info details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildInfoRow('Name', _user!.name),
                  _buildInfoRow('Email', _user!.email),
                  _buildInfoRow(
                      'Role', _user!.roleId == 1 ? 'Admin' : 'Customer'),
                  _buildInfoRow('Member Since', 'January 2024'),
                ],
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('$feature'),
        content:
            Text('$feature feature is coming soon! Stay tuned for updates.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
