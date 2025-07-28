import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/pages/kategori_page.dart';
import 'package:tugasakhir_mobile/pages/login_page.dart';
import 'package:tugasakhir_mobile/pages/produk_page.dart';
import 'package:tugasakhir_mobile/services/auth_service.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';
import 'package:tugasakhir_mobile/pages/admin_orders_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  late TabController _tabController;
  final List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  final List<double> _salesData = [10500, 15000, 8000, 25000, 22000, 18000];

  // Dummy data for charts
  final List<Map<String, dynamic>> _recentUsers = [
    {
      'name': 'Aditya Pratama',
      'email': 'aditya@gmail.com',
      'date': '2 jam yang lalu',
      'avatar': 'AP',
    },
    {
      'name': 'Budi Santoso',
      'email': 'budi@gmail.com',
      'date': '5 jam yang lalu',
      'avatar': 'BS',
    },
    {
      'name': 'Citra Dewi',
      'email': 'citra@gmail.com',
      'date': '1 hari yang lalu',
      'avatar': 'CD',
    },
    {
      'name': 'Dodi Wijaya',
      'email': 'dodi@gmail.com',
      'date': '2 hari yang lalu',
      'avatar': 'DW',
    },
  ];

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 'ORD-001',
      'customer': 'Aditya P.',
      'amount': 'Rp 350.000',
      'status': 'Selesai',
      'statusColor': Colors.green,
    },
    {
      'id': 'ORD-002',
      'customer': 'Budi S.',
      'amount': 'Rp 120.000',
      'status': 'Diproses',
      'statusColor': Colors.orange,
    },
    {
      'id': 'ORD-003',
      'customer': 'Citra D.',
      'amount': 'Rp 475.000',
      'status': 'Selesai',
      'statusColor': Colors.green,
    },
    {
      'id': 'ORD-004',
      'customer': 'Dodi W.',
      'amount': 'Rp 250.000',
      'status': 'Dibatalkan',
      'statusColor': Colors.red,
    },
  ];

  // Menu admin
  final List<Map<String, dynamic>> _adminMenus = [
    {
      'title': 'Pengguna',
      'icon': Icons.people,
      'color': Colors.blue,
      'route': null,
    },
    {
      'title': 'Produk',
      'icon': Icons.inventory,
      'color': Colors.green,
      'route': ProdukPage(),
    },
    {
      'title': 'Kategori',
      'icon': Icons.category,
      'color': Colors.indigo,
      'route': KategoriPage(),
    },
    {
      'title': 'Pesanan',
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
      'route': const AdminOrdersPage(),
    },
    {
      'title': 'Laporan',
      'icon': Icons.bar_chart,
      'color': Colors.purple,
      'route': null,
    },
    {
      'title': 'Pengaturan',
      'icon': Icons.settings,
      'color': Colors.grey,
      'route': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _navigateToMenu(int index) {
    final menu = _adminMenus[index];
    if (menu['route'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => menu['route']),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu ${menu["title"]} akan segera hadir')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildStatCards(),
                    const SizedBox(height: 20),
                    _buildAdminMenus(),
                    const SizedBox(height: 20),
                    _buildChartSection(),
                    const SizedBox(height: 20),
                    _buildTabSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[700], // Make selected color more visible
        unselectedItemColor:
            Colors.grey[600], // Make unselected color more visible
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 8, // Add elevation for better visibility
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            activeIcon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            // Navigate to orders page when Orders tab is selected
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminOrdersPage()),
            );
          } else if (index != 0) {
            // Show coming soon for other tabs
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur ini akan segera hadir'),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tambah produk baru akan segera hadir'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Admin Dashboard",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifikasi akan segera hadir'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _logout,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 16,
                  child: Text(
                    _user?.name.isNotEmpty == true
                        ? _user!.name[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[800]!, Colors.indigo[900]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, ${_user?.name ?? "Admin"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Senin, ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan akan segera hadir'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Laporan Harian'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              'Pengguna',
              '128',
              '↑ 12%',
              Icons.people_alt_outlined,
              Colors.blue,
              const Color(0xFFeef7ff),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Produk',
              '534',
              '↑ 8%',
              Icons.shopping_bag_outlined,
              Colors.green,
              const Color(0xFFe6f7ed),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'Transaksi',
              '86',
              '↑ 24%',
              Icons.receipt_long_outlined,
              Colors.orange,
              const Color(0xFFfef4e6),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Pendapatan',
              'Rp 15,4 Jt',
              '↑ 18%',
              Icons.attach_money,
              Colors.purple,
              const Color(0xFFf5e6f9),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminMenus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Admin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: _adminMenus.length,
          itemBuilder: (context, index) {
            final menu = _adminMenus[index];
            return GestureDetector(
              onTap: () => _navigateToMenu(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: menu['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(menu['icon'], color: menu['color'], size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menu['title'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (menu['route'] != null) const SizedBox(height: 4),
                    if (menu['route'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Tersedia',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String growth,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  growth,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penjualan Bulanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      '6 Bulan Terakhir',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    double maxValue = _salesData.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_months.length, (index) {
        // Calculate the height percentage based on max value
        double heightPercentage = _salesData[index] / maxValue;

        return Expanded(
          child: Column(
            children: [
              Text(
                '${(_salesData[index] / 1000).toStringAsFixed(0)}K',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Penjualan ${_months[index]}: Rp ${_salesData[index].toStringAsFixed(0)}',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 20,
                  height: 150 * heightPercentage,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.blue[300]!, Colors.blue[800]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _months[index],
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Pengguna Baru'),
                  Tab(text: 'Pesanan'),
                  Tab(text: 'Produk'),
                ],
              ),
              SizedBox(
                height: 280,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecentUsersList(),
                    _buildRecentOrdersList(),
                    _buildProductsGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUsersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentUsers.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = _recentUsers[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.primaries[index % Colors.primaries.length],
            child: Text(
              user['avatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            user['name'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(user['email']),
          trailing: Text(
            user['date'],
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        );
      },
    );
  }

  Widget _buildRecentOrdersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentOrders.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final order = _recentOrders[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            order['id'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(order['customer']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order['amount'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: order['statusColor'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final color = Colors.primaries[index % Colors.primaries.length];
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                [
                  Icons.smartphone,
                  Icons.laptop,
                  Icons.headphones,
                  Icons.watch,
                  Icons.camera,
                  Icons.speaker,
                ][index],
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                [
                  'Smartphone',
                  'Laptop',
                  'Headphones',
                  'Smart Watch',
                  'Camera',
                  'Speaker',
                ][index],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  '45 item',
                  '32 item',
                  '28 item',
                  '19 item',
                  '12 item',
                  '24 item',
                ][index],
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
