import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugasakhir_mobile/models/kategori_model.dart';
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/pages/cart_page.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/pages/product_detail_page.dart'; // Added import for ProductDetailPage
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'package:tugasakhir_mobile/services/cart_service.dart';
import 'package:tugasakhir_mobile/services/kategori_service.dart';
import 'package:tugasakhir_mobile/services/produk_service.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final KategoriService _kategoriService = KategoriService();
  final ProdukService _produkService = ProdukService();

  // Format currency
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  UserModel? _user;
  bool _isLoading = true;
  int _selectedNavIndex = 0;

  // Data dari API
  List<KategoriModel> _kategoriList = [];
  List<ProdukModel> _produkList = [];
  String? _errorMessage;

  // Gambar lokal untuk slider
  final List<String> _bannerImages = [
    'assets/images/slider1.jpg',
    'assets/images/slider2.jpg',
    'assets/images/slider3.jpg',
  ];

  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user data
      await _loadUserData();

      // Load categories
      final kategoriResult = await _kategoriService.getAllKategori();

      // Load products
      final produkResult = await _produkService.getAllProduk();

      setState(() {
        _isLoading = false;

        if (kategoriResult['success']) {
          _kategoriList = kategoriResult['data'];
        }

        if (produkResult['success']) {
          _produkList = produkResult['data'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  Future<void> _loadUserData() async {
    final userJson = await StorageHelper.getUser();
    if (userJson != null) {
      setState(() {
        _user = UserModel.fromJson(jsonDecode(userJson));
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

  // Update method untuk handle bottom navigation
  void _onNavigationTap(int index) {
    if (_selectedNavIndex == index)
      return; // Jika sudah di halaman yang sama, tidak perlu navigasi lagi

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0: // Home - sudah di home, tidak perlu navigasi
        break;
      case 1: // Saved
        _showComingSoonDialog();
        break;
      case 2: // Cart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        ).then((_) {
          // Reset selected index ke 0 (home) setelah kembali dari Cart
          setState(() {
            _selectedNavIndex = 0;
          });
        });
        break;
      case 3: // Account
        _showComingSoonDialog();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
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
                _buildCategoriesRow(),

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
                                    image: AssetImage(_bannerImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                  color: _currentBannerIndex == index
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

                // Hot Deals section (Produk)
                _buildProductsSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavIndex,
        onTap: _onNavigationTap,
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

  Widget _buildCategoriesRow() {
    if (_kategoriList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: Text(
            'Belum ada kategori',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Tampilkan maksimal 5 kategori
    final displayedKategori =
        _kategoriList.length > 5 ? _kategoriList.sublist(0, 5) : _kategoriList;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: displayedKategori.map((kategori) {
            return GestureDetector(
              onTap: _showComingSoonDialog,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kategori.namaKategori,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16, 8, 16, 24), // Tambahkan padding bawah lebih besar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_produkList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Belum ada produk',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    0.7, // Ubah dari 0.8 menjadi 0.7 untuk memberikan ruang lebih tinggi
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _produkList.length > 4
                  ? 4
                  : _produkList.length, // Tampilkan maksimal 4 produk
              itemBuilder: (context, index) {
                final produk = _produkList[index];
                final stokInt = produk.getStokAsInt();
                final stokColor = stokInt > 20
                    ? Colors.green
                    : stokInt > 5
                        ? Colors.orange
                        : Colors.red;

                return GestureDetector(
                  onTap: () => _navigateToProductDetail(produk),
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
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: produk.gambarProduk != null &&
                                        produk.gambarProduk!.isNotEmpty
                                    ? Image.network(
                                        produk.getImageUrl() ?? '',
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons.inventory_2_outlined,
                                                    color: Colors.grey),
                                                const SizedBox(height: 8),
                                                Text(
                                                  produk.namaProduk,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 48,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: stokColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Stok: $stokInt',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: stokColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          // Wrap in Expanded to prevent overflow
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize.min, // Use minimum space needed
                              children: [
                                Text(
                                  produk.namaProduk,
                                  maxLines:
                                      1, // Limit to 1 line to prevent overflow
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat
                                      .format(produk.getHargaAsInt()),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.green[700],
                                  ),
                                ),
                                if (produk.kategori != null)
                                  Text(
                                    produk.kategori!.namaKategori,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
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
    );
  }

  // Navigasi ke halaman detail produk
  void _navigateToProductDetail(ProdukModel produk) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: produk),
      ),
    );
  }
}
