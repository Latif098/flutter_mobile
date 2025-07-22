import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tugasakhir_mobile/models/kategori_model.dart';
import 'package:tugasakhir_mobile/services/kategori_service.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({Key? key}) : super(key: key);

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage>
    with SingleTickerProviderStateMixin {
  final KategoriService _kategoriService = KategoriService();
  final TextEditingController _kategoriController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isAdding = false;
  bool _isDeleting = false;
  String? _errorMessage;
  List<KategoriModel> _kategoriList = [];
  Map<String, List<String>>? _validationErrors;
  bool _isExpanded = false;

  // Alert dialog state
  bool _showSuccessAlert = false;
  String _alertMessage = '';
  late AnimationController _alertAnimationController;
  late Animation<double> _alertAnimation;

  // Random colors for category cards
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.amber,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.orange,
    Colors.deepOrange,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _loadKategori();

    // Setup animation for alert
    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _alertAnimation = CurvedAnimation(
      parent: _alertAnimationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _kategoriController.dispose();
    _alertAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getRandomColor(int index) {
    return _colors[index % _colors.length].withOpacity(0.7);
  }

  void _showAlert(String message) {
    setState(() {
      _alertMessage = message;
      _showSuccessAlert = true;
    });
    _alertAnimationController.forward();

    // Hide alert after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _alertAnimationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showSuccessAlert = false;
            });
          }
        });
      }
    });
  }

  Future<void> _loadKategori() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _kategoriService.getAllKategori();

      setState(() {
        _isLoading = false;
        if (result['success']) {
          _kategoriList = result['data'];
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  Future<void> _addKategori() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAdding = true;
      _validationErrors = null;
    });

    try {
      final result = await _kategoriService.createKategori(
        _kategoriController.text.trim(),
      );

      if (result['success']) {
        _kategoriController.clear();
        _showAlert(result['message']);
        _loadKategori();

        // Collapse form after successful add
        setState(() {
          _isExpanded = false;
        });

        // Scroll to top to see new category
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      } else {
        setState(() {
          _validationErrors =
              result['errors'] != null
                  ? Map<String, List<String>>.from(result['errors'])
                  : null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  Future<void> _confirmDeleteKategori(KategoriModel kategori) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus kategori "${kategori.namaKategori}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteKategori(kategori.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteKategori(int id) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await _kategoriService.deleteKategori(id);

      if (result['success']) {
        _showAlert(result['message']);
        _loadKategori();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kelola Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadKategori,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAddKategoriButton()),
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: _isExpanded ? null : 0,
                  child: _isExpanded ? _buildAddKategoriForm() : Container(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Kategori (${_kategoriList.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildSortFilterButton(),
                    ],
                  ),
                ),
              ),
              _buildKategoriGrid(),
            ],
          ),
          // Modern success alert
          if (_showSuccessAlert)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ScaleTransition(
                    scale: _alertAnimation,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
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
                          Text(
                            _alertMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Loading overlay
          if (_isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (!_isExpanded && _scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
        backgroundColor: Colors.indigo,
        child: Icon(_isExpanded ? Icons.close : Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAddKategoriButton() {
    return const SizedBox.shrink(); // Menggunakan FloatingActionButton sebagai gantinya
  }

  Widget _buildSortFilterButton() {
    return IconButton(
      icon: const Icon(Icons.sort),
      onPressed: () {
        setState(() {
          // Reverse the list for simple sorting
          _kategoriList = _kategoriList.reversed.toList();
        });
      },
      tooltip: 'Urutkan',
      splashRadius: 24,
      color: Colors.grey[700],
    );
  }

  Widget _buildAddKategoriForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.add_circle,
                        color: Colors.indigo,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tambah Kategori Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        splashRadius: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kategoriController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      hintText: 'Masukkan nama kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                      errorText:
                          _validationErrors != null &&
                                  _validationErrors!.containsKey(
                                    'nama_kategori',
                                  )
                              ? _validationErrors!['nama_kategori']![0]
                              : null,
                      suffixIcon:
                          _kategoriController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed:
                                    () => setState(() {
                                      _kategoriController.clear();
                                    }),
                              )
                              : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama kategori tidak boleh kosong';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addKategori,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.indigo.withOpacity(0.5),
                        elevation: 3,
                      ),
                      child:
                          _isAdding
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tambah Kategori',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadKategori,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_kategoriList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: Colors.grey[400],
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada kategori',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tambahkan kategori baru dengan tombol di bawah',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Tambah Kategori Baru',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use a staggered grid for a more interesting layout
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final kategori = _kategoriList[index];
          final color = _getRandomColor(index);

          return _buildKategoriCard(kategori, color);
        }, childCount: _kategoriList.length),
      ),
    );
  }

  Widget _buildKategoriCard(KategoriModel kategori, Color color) {
    return Hero(
      tag: 'kategori-${kategori.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showKategoriDetail(kategori, color);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.category,
                    size: 100,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              kategori.namaKategori[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _confirmDeleteKategori(kategori),
                            iconSize: 20,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        kategori.namaKategori,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: ${kategori.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
      ),
    );
  }

  void _showKategoriDetail(KategoriModel kategori, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: color,
                      child: Text(
                        kategori.namaKategori[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      kategori.namaKategori,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailItem(
                      icon: Icons.numbers,
                      title: 'ID',
                      value: kategori.id.toString(),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      title: 'Dibuat pada',
                      value:
                          kategori.createdAt != null
                              ? _formatDate(kategori.createdAt!)
                              : 'Tidak ada data',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailItem(
                      icon: Icons.update,
                      title: 'Diperbarui pada',
                      value:
                          kategori.updatedAt != null
                              ? _formatDate(kategori.updatedAt!)
                              : 'Tidak ada data',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Delete button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteKategori(kategori);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text(
                      'Hapus Kategori',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.indigo),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }
}
