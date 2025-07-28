import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugasakhir_mobile/models/kategori_model.dart';
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/models/address_model.dart';
import 'package:tugasakhir_mobile/pages/cart_page.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/pages/product_detail_page.dart';
import 'package:tugasakhir_mobile/pages/profile_page.dart';
import 'package:tugasakhir_mobile/pages/wishlist_page.dart';
import 'package:tugasakhir_mobile/pages/address_page.dart';
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'package:tugasakhir_mobile/services/cart_service.dart';
import 'package:tugasakhir_mobile/services/kategori_service.dart';
import 'package:tugasakhir_mobile/services/produk_service.dart';
import 'package:tugasakhir_mobile/services/address_service.dart';
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
  final AddressService _addressService = AddressService();

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
  List<ProdukModel> _filteredProdukList = [];
  String? _errorMessage;

  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  int? _selectedKategoriId;
  String _searchQuery = '';

  // Address data
  List<AddressModel> _savedAddresses = [];
  AddressModel? _currentAddress;
  String _defaultLocationText = 'Pilih alamat';

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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      _filteredProdukList = _produkList.where((produk) {
        final matchesSearch = _searchQuery.isEmpty ||
            produk.namaProduk
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesCategory = _selectedKategoriId == null ||
            produk.kategoriProdukId == _selectedKategoriId;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user data
      await _loadUserData();

      // Load addresses
      await _loadAddresses();

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
          _filterProducts(); // Apply initial filter
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

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _addressService.getSavedAddresses();
      final defaultAddress = await _addressService.getDefaultAddress();

      setState(() {
        _savedAddresses = addresses;
        _currentAddress = defaultAddress;
      });
    } catch (e) {
      print('Error loading addresses: ${e.toString()}');
      // Set default jika tidak ada alamat
      setState(() {
        _savedAddresses = [];
        _currentAddress = null;
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildHomeContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistPage()),
              ).then((_) => setState(() => _selectedNavIndex = 0));
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              ).then((_) => setState(() => _selectedNavIndex = 0));
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ).then((_) => setState(() => _selectedNavIndex = 0));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Add this method with the original content from the home page build method
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Header with notification
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showLocationDialog,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _currentAddress?.address ?? _defaultLocationText,
                              style: TextStyle(
                                color: _currentAddress != null
                                    ? Colors.blue
                                    : Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: _currentAddress != null
                                  ? Colors.blue
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Find your favorite items',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                            size: 24,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Scan/Filter functionality
                        _showFilterDialog();
                      },
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Banner Slider
            Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _bannerImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(_bannerImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Banner Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerImages.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerIndex == index
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),

            // Categories Section
            _buildCategorySection(),

            // Products Section
            _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedKategoriId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedKategoriId = null;
                      });
                      _filterProducts();
                      Navigator.pop(context);
                    },
                  ),
                  ..._kategoriList.map((kategori) {
                    return FilterChip(
                      label: Text(kategori.namaKategori),
                      selected: _selectedKategoriId == kategori.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedKategoriId = selected ? kategori.id : null;
                        });
                        _filterProducts();
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationDialog() {
    if (_savedAddresses.isEmpty) {
      // Jika belum ada alamat, navigasi ke halaman address
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddressPage()),
      ).then((_) => _loadAddresses());
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Address',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddressPage()),
                      ).then((_) => _loadAddresses());
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._savedAddresses.map((address) {
                final isSelected = _currentAddress?.id == address.id;
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    address.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    address.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _currentAddress = address;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Rename the method to match its call in _buildHomeContent
  Widget _buildCategorySection() {
    if (_kategoriList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  onPressed: () {
                    _showFilterDialog();
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _kategoriList.asMap().entries.map((entry) {
                final kategori = entry.value;
                final index = entry.key;
                final isSelected = _selectedKategoriId == kategori.id;

                // Get icon and color based on category name keywords
                final iconData = _getCategoryIcon(kategori.namaKategori);
                final color = _getCategoryColor(kategori.namaKategori);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedKategoriId = isSelected ? null : kategori.id;
                    });
                    _filterProducts();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < _kategoriList.length - 1 ? 16 : 0,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            iconData,
                            color: isSelected ? Colors.white : color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            _formatCategoryName(kategori.namaKategori),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected ? color : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk mendapatkan ikon berdasarkan kata kunci dalam nama kategori
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    // Fashion & Clothing
    if (name.contains('fashion') ||
        name.contains('pakaian') ||
        name.contains('baju') ||
        name.contains('celana') ||
        name.contains('kemeja') ||
        name.contains('dress')) {
      return Icons.checkroom;
    }

    // Electronics & Technology
    if (name.contains('elektronik') ||
        name.contains('gadget') ||
        name.contains('hp') ||
        name.contains('laptop') ||
        name.contains('komputer') ||
        name.contains('teknologi')) {
      return Icons.devices;
    }

    // Sports & Fitness
    if (name.contains('olahraga') ||
        name.contains('fitness') ||
        name.contains('sport') ||
        name.contains('gym') ||
        name.contains('sepatu')) {
      return Icons.fitness_center;
    }

    // Food & Beverages
    if (name.contains('makanan') ||
        name.contains('makan') ||
        name.contains('food') ||
        name.contains('snack') ||
        name.contains('cemilan')) {
      return Icons.restaurant;
    }
    if (name.contains('minuman') ||
        name.contains('minum') ||
        name.contains('drink') ||
        name.contains('jus') ||
        name.contains('kopi')) {
      return Icons.local_drink;
    }

    // Health & Beauty
    if (name.contains('kesehatan') ||
        name.contains('obat') ||
        name.contains('vitamin') ||
        name.contains('health') ||
        name.contains('medis')) {
      return Icons.health_and_safety;
    }
    if (name.contains('kecantikan') ||
        name.contains('kosmetik') ||
        name.contains('beauty') ||
        name.contains('skincare') ||
        name.contains('makeup')) {
      return Icons.face;
    }

    // Home & Living
    if (name.contains('rumah') ||
        name.contains('home') ||
        name.contains('furniture') ||
        name.contains('dekorasi') ||
        name.contains('perabot')) {
      return Icons.home;
    }
    if (name.contains('dapur') ||
        name.contains('kitchen') ||
        name.contains('masak') ||
        name.contains('peralatan')) {
      return Icons.kitchen;
    }

    // Books & Education
    if (name.contains('buku') ||
        name.contains('book') ||
        name.contains('pendidikan') ||
        name.contains('edukasi') ||
        name.contains('sekolah')) {
      return Icons.menu_book;
    }

    // Automotive
    if (name.contains('otomotif') ||
        name.contains('mobil') ||
        name.contains('motor') ||
        name.contains('kendaraan') ||
        name.contains('automotive')) {
      return Icons.directions_car;
    }

    // Toys & Games
    if (name.contains('mainan') ||
        name.contains('toy') ||
        name.contains('game') ||
        name.contains('permainan') ||
        name.contains('anak')) {
      return Icons.toys;
    }

    // Office & Stationery
    if (name.contains('kantor') ||
        name.contains('office') ||
        name.contains('alat tulis') ||
        name.contains('stationery') ||
        name.contains('kertas')) {
      return Icons.edit;
    }

    // Baby & Kids
    if (name.contains('bayi') ||
        name.contains('baby') ||
        name.contains('anak') ||
        name.contains('kids') ||
        name.contains('balita')) {
      return Icons.child_friendly;
    }

    // Tools & Hardware
    if (name.contains('alat') ||
        name.contains('tool') ||
        name.contains('perkakas') ||
        name.contains('hardware') ||
        name.contains('teknik')) {
      return Icons.build;
    }

    // Default icon
    return Icons.category;
  }

  // Method untuk mendapatkan warna berdasarkan kata kunci dalam nama kategori
  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('fashion') ||
        name.contains('pakaian') ||
        name.contains('baju')) {
      return Colors.purple;
    }
    if (name.contains('elektronik') ||
        name.contains('gadget') ||
        name.contains('teknologi')) {
      return Colors.indigo;
    }
    if (name.contains('olahraga') ||
        name.contains('fitness') ||
        name.contains('sport')) {
      return Colors.green;
    }
    if (name.contains('makanan') || name.contains('food')) {
      return Colors.orange;
    }
    if (name.contains('minuman') || name.contains('drink')) {
      return Colors.cyan;
    }
    if (name.contains('kesehatan') || name.contains('health')) {
      return Colors.red;
    }
    if (name.contains('kecantikan') || name.contains('beauty')) {
      return Colors.pink;
    }
    if (name.contains('rumah') ||
        name.contains('home') ||
        name.contains('furniture')) {
      return Colors.brown;
    }
    if (name.contains('otomotif') ||
        name.contains('mobil') ||
        name.contains('motor')) {
      return Colors.grey;
    }
    if (name.contains('mainan') ||
        name.contains('game') ||
        name.contains('anak')) {
      return Colors.amber;
    }

    // Default color
    return Colors.blue;
  }

  // Method untuk memformat nama kategori agar lebih rapi
  String _formatCategoryName(String categoryName) {
    // Jika nama terlalu panjang, coba singkat dengan menghilangkan kata-kata umum
    if (categoryName.length > 12) {
      String formatted = categoryName;

      // Hapus kata-kata umum yang tidak penting
      formatted = formatted.replaceAll('dan ', '');
      formatted = formatted.replaceAll(' dan', '');
      formatted = formatted.replaceAll('untuk ', '');
      formatted = formatted.replaceAll(' untuk', '');
      formatted = formatted.replaceAll('serta ', '');
      formatted = formatted.replaceAll(' serta', '');

      // Jika masih terlalu panjang, ambil kata pertama dan terakhir
      if (formatted.length > 12) {
        final words = formatted.split(' ');
        if (words.length > 1) {
          // Ambil kata pertama dan terakhir
          return '${words.first}\n${words.last}';
        }
      }

      return formatted;
    }

    return categoryName;
  }

  Widget _buildProductsSection() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedKategoriId == null
                    ? 'Products'
                    : 'Filtered Products (${_filteredProdukList.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedKategoriId != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedKategoriId = null;
                      _searchController.clear();
                    });
                    _filterProducts();
                  },
                  child: Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_filteredProdukList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No products found for "$_searchQuery"'
                          : _selectedKategoriId != null
                              ? 'No products in this category'
                              : 'No products available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProdukList.length,
              itemBuilder: (context, index) {
                final produk = _filteredProdukList[index];
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .inventory_2_outlined,
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
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey[200],
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
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Stock: $stokInt',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: stokColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  produk.namaProduk,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat
                                      .format(produk.getHargaAsInt()),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                if (produk.kategori != null) ...[
                                  const SizedBox(height: 4),
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
