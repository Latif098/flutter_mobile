import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  int _selectedNavIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Fitness', 'icon': Icons.fitness_center},
    {'name': 'Living', 'icon': Icons.weekend},
    {'name': 'Games', 'icon': Icons.sports_esports},
    {'name': 'Stationery', 'icon': Icons.edit},
  ];

  final List<String> _bannerImages = [
    'https://via.placeholder.com/800x300/2D7CDB/FFFFFF?text=Big+Sale+Up+to+50%',
    'https://via.placeholder.com/800x300/FF5733/FFFFFF?text=Special+Offer',
    'https://via.placeholder.com/800x300/27AE60/FFFFFF?text=New+Arrival',
    'https://via.placeholder.com/800x300/8E44AD/FFFFFF?text=Flash+Sale',
    'https://via.placeholder.com/800x300/F39C12/FFFFFF?text=Weekend+Deals',
  ];

  final List<Map<String, dynamic>> _hotDeals = [
    {
      'name': 'Portable Neck Fan Hands Free Fan',
      'price': 'Rp 150.000',
      'image':
          'https://via.placeholder.com/200x200/DDDDDD/333333?text=Portable+Fan',
    },
    {
      'name': 'Refurbished Echo Dot',
      'price': 'Rp 650.000',
      'image':
          'https://via.placeholder.com/200x200/DDDDDD/333333?text=Echo+Dot',
    },
    {
      'name': 'Smart Watch Pro',
      'price': 'Rp 1.200.000',
      'image':
          'https://via.placeholder.com/200x200/DDDDDD/333333?text=Smart+Watch',
    },
    {
      'name': 'Wireless Earbuds',
      'price': 'Rp 350.000',
      'image': 'https://via.placeholder.com/200x200/DDDDDD/333333?text=Earbuds',
    },
  ];

  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.logout();

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal logout')));
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon!'),
          content: const Text(
            'Fitur ini akan segera hadir. Silakan tunggu update selanjutnya!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and notification bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            'Padang, Sumatera Barat',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black,
                        ),
                        onPressed: _showComingSoonDialog,
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(Icons.search, color: Colors.blue[600]),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Find your favorite items',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _showComingSoonDialog,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        _categories.map((category) {
                          return GestureDetector(
                            onTap: _showComingSoonDialog,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    category['icon'],
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['name'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),

                // Banner slider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AspectRatio(
                    aspectRatio: 16 / 8,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _bannerController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentBannerIndex = page;
                            });
                          },
                          itemCount: _bannerImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: _showComingSoonDialog,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(_bannerImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child:
                                    index == 0
                                        ? Stack(
                                          children: [
                                            Positioned(
                                              left: 20,
                                              bottom: 20,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Big Sale',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Up to 50%',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[800],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Happening Now',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                        : null,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _bannerImages.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentBannerIndex == index
                                          ? Colors.blue[600]
                                          : Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hot Deals section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hot Deals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _hotDeals.length < 4 ? _hotDeals.length : 4,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: _showComingSoonDialog,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.network(
                                            _hotDeals[index]['image'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showComingSoonDialog();
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite_border,
                                              size: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _hotDeals[index]['name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _hotDeals[index]['price'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index != 0) {
            _showComingSoonDialog();
          }
        },
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
