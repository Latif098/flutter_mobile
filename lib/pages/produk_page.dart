import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugasakhir_mobile/models/kategori_model.dart';
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/services/kategori_service.dart';
import 'package:tugasakhir_mobile/services/produk_service.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage>
    with SingleTickerProviderStateMixin {
  final ProdukService _produkService = ProdukService();
  final KategoriService _kategoriService = KategoriService();

  // Controllers for adding/editing
  final _formKey = GlobalKey<FormState>();
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  List<ProdukModel> _produkList = [];
  List<KategoriModel> _kategoriList = [];
  KategoriModel? _selectedKategori;
  Map<String, List<String>>? _validationErrors;

  ProdukModel? _editingProduk;

  // Format currency
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Animation
  late AnimationController _animationController;
  bool _showForm = false;

  // Alert dialog state
  bool _showSuccessAlert = false;
  String _alertMessage = '';
  late Animation<double> _alertAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Set up animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Setup animation for alert
    _alertAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAlert(String message) {
    setState(() {
      _alertMessage = message;
      _showSuccessAlert = true;
    });
    _animationController.forward();

    // Hide alert after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showSuccessAlert = false;
            });
          }
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load products
      final produkResult = await _produkService.getAllProduk();

      // Load categories
      final kategoriResult = await _kategoriService.getAllKategori();

      setState(() {
        _isLoading = false;

        if (produkResult['success']) {
          _produkList = produkResult['data'];
        } else {
          _errorMessage = produkResult['message'];
        }

        if (kategoriResult['success']) {
          _kategoriList = kategoriResult['data'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  void _resetForm() {
    _namaProdukController.clear();
    _hargaController.clear();
    _stokController.clear();
    _selectedKategori = null;
    _editingProduk = null;
    _validationErrors = null;
  }

  void _setupForEdit(ProdukModel produk) {
    _namaProdukController.text = produk.namaProduk;
    _hargaController.text = produk.harga.toString();
    _stokController.text = produk.stok.toString();

    // Perbaikan untuk error tipe nullable
    _selectedKategori = _kategoriList.firstWhere(
      (k) => k.id == produk.kategoriProdukId,
      orElse: () => _kategoriList.isNotEmpty
          ? _kategoriList.first
          : _createDummyKategori(),
    );

    _editingProduk = produk;

    _toggleForm(true);
  }

  // Membuat kategori dummy untuk handle kasus kosong
  KategoriModel _createDummyKategori() {
    return KategoriModel(id: -1, namaKategori: 'Kategori Tidak Tersedia');
  }

  void _toggleForm(bool show) {
    setState(() {
      _showForm = show;
    });

    if (show) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _resetForm();
    }
  }

  Future<void> _saveProduk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _validationErrors = null;
    });

    try {
      final Map<String, dynamic> result;

      // Parse input values
      final String namaProduk = _namaProdukController.text.trim();
      final int harga =
          int.parse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final int stok = int.parse(_stokController.text);
      final int kategoriId = _selectedKategori!.id;

      if (_editingProduk == null) {
        // Create new product
        result = await _produkService.createProduk(
          namaProduk: namaProduk,
          harga: harga,
          stok: stok,
          kategoriProdukId: kategoriId,
        );
      } else {
        // Update existing product
        result = await _produkService.updateProduk(
          id: _editingProduk!.id,
          namaProduk: namaProduk,
          harga: harga,
          stok: stok,
          kategoriProdukId: kategoriId,
        );
      }

      if (result['success']) {
        _showAlert(result['message']);
        _toggleForm(false);
        _loadData();
      } else {
        setState(() {
          _validationErrors = result['errors'] != null
              ? Map<String, List<String>>.from(result['errors'])
              : null;
          _showSnackBar(result['message']);
        });
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _confirmDeleteProduk(ProdukModel produk) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content:
            Text('Apakah Anda yakin ingin menghapus "${produk.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteProduk(produk.id);
    }
  }

  Future<void> _deleteProduk(int id) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _produkService.deleteProduk(id);

      if (result['success']) {
        _showAlert(result['message']);
        _loadData();
      } else {
        _showSnackBar(result['message']);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kelola Produk',
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
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),

          // Form overlay
          if (_showForm) _buildFormOverlay(),

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

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleForm(true),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
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
      );
    }

    if (_produkList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 80),
            const SizedBox(height: 16),
            Text(
              'Belum ada produk',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk baru dengan tombol +',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _produkList.length,
      itemBuilder: (context, index) {
        final produk = _produkList[index];
        return _buildProductCard(produk);
      },
    );
  }

  Widget _buildProductCard(ProdukModel produk) {
    final kategoriName = produk.kategori?.namaKategori ?? 'Tidak ada kategori';
    final stokColor = produk.stok > 20
        ? Colors.green
        : produk.stok > 5
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _setupForEdit(produk),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category name
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    kategoriName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: stokColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Stok: ${produk.stok}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: stokColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.namaProduk,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(produk.harga),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _setupForEdit(produk),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteProduk(produk),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
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

  Widget _buildFormOverlay() {
    return GestureDetector(
      onTap: () => _toggleForm(false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            )),
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on form
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _editingProduk == null
                                ? 'Tambah Produk Baru'
                                : 'Edit Produk',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _toggleForm(false),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildProductForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama produk field
          TextFormField(
            controller: _namaProdukController,
            decoration: InputDecoration(
              labelText: 'Nama Produk',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.shopping_bag),
              errorText: _validationErrors != null &&
                      _validationErrors!.containsKey('nama_produk')
                  ? _validationErrors!['nama_produk']![0]
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama produk tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Harga field
          TextFormField(
            controller: _hargaController,
            decoration: InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.monetization_on),
              errorText: _validationErrors != null &&
                      _validationErrors!.containsKey('harga')
                  ? _validationErrors!['harga']![0]
                  : null,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Harga tidak boleh kosong';
              }
              final numValue =
                  int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
              if (numValue == null || numValue <= 0) {
                return 'Harga harus berupa angka positif';
              }
              return null;
            },
            onChanged: (value) {
              // Format currency on change
              if (value.isNotEmpty) {
                final numValue =
                    int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                _hargaController.value = TextEditingValue(
                  text: _currencyFormat.format(numValue),
                  selection: TextSelection.collapsed(
                      offset: _currencyFormat.format(numValue).length),
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Stok field
          TextFormField(
            controller: _stokController,
            decoration: InputDecoration(
              labelText: 'Stok',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.inventory),
              errorText: _validationErrors != null &&
                      _validationErrors!.containsKey('stok')
                  ? _validationErrors!['stok']![0]
                  : null,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Stok tidak boleh kosong';
              }
              final numValue = int.tryParse(value);
              if (numValue == null || numValue < 0) {
                return 'Stok harus berupa angka positif';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Kategori field
          _buildKategoriDropdown(),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _saveProduk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _editingProduk == null
                          ? 'Tambah Produk'
                          : 'Perbarui Produk',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<KategoriModel>(
              isExpanded: true,
              hint: const Text('Pilih Kategori'),
              value: _selectedKategori,
              items: _kategoriList.map((KategoriModel kategori) {
                return DropdownMenuItem<KategoriModel>(
                  value: kategori,
                  child: Text(kategori.namaKategori),
                );
              }).toList(),
              onChanged: (KategoriModel? value) {
                setState(() {
                  _selectedKategori = value;
                });
              },
            ),
          ),
        ),
        if (_validationErrors != null &&
            _validationErrors!.containsKey('kategori_produk_id'))
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _validationErrors!['kategori_produk_id']![0],
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
