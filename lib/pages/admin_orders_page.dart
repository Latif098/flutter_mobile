import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugasakhir_mobile/models/pesanan_model.dart';
import 'package:tugasakhir_mobile/services/pesanan_service.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final PesananService _pesananService = PesananService();
  bool _isLoading = true;
  List<PesananModel> _orders = [];
  Set<int> _rejectedOrderIds = {}; // Track locally rejected orders
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Pending',
    'Processing',
    'Completed',
    'Rejected'
  ];

  // Currency formatter
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadRejectedOrderIds();
    _loadAllOrders();
  }

  // Load rejected order IDs from local storage
  Future<void> _loadRejectedOrderIds() async {
    try {
      final rejectedIds = await StorageHelper.getRejectedOrderIds();
      setState(() {
        _rejectedOrderIds = rejectedIds.toSet();
      });
      print('Loaded ${_rejectedOrderIds.length} rejected order IDs');
    } catch (e) {
      print('Error loading rejected order IDs: $e');
    }
  }

  // Save rejected order ID to local storage
  Future<void> _saveRejectedOrderId(int orderId) async {
    try {
      _rejectedOrderIds.add(orderId);
      await StorageHelper.saveRejectedOrderIds(_rejectedOrderIds.toList());
      print('Saved rejected order ID: $orderId');
    } catch (e) {
      print('Error saving rejected order ID: $e');
    }
  }

  // Check if order is rejected locally
  bool _isOrderRejected(PesananModel order) {
    return _rejectedOrderIds.contains(order.id);
  }

  // Get effective status (considering local rejection tracking and database status)
  String _getEffectiveStatus(PesananModel order) {
    final dbStatus = order.status.toLowerCase();

    // Check if status from database is 'ditolak'
    if (dbStatus == 'ditolak') {
      return 'rejected';
    }

    // Also check local tracking (fallback)
    if (_isOrderRejected(order)) {
      return 'rejected';
    }

    return dbStatus;
  }

  // Get display status (user-friendly format)
  String _getDisplayStatus(PesananModel order) {
    final dbStatus = order.status.toLowerCase();

    // Convert database status to display format
    switch (dbStatus) {
      case 'ditolak':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
      case 'selesai':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        // Check local tracking
        if (_isOrderRejected(order)) {
          return 'Rejected';
        }
        return order.status; // Return original status if not recognized
    }
  }

  Future<void> _loadAllOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _pesananService.getAllOrders();

      // Debug: Print order statuses for verification
      print('=== Order Status Check ===');
      final rejectedCount =
          result.where((o) => o.status.toLowerCase() == 'ditolak').length;
      print('Found $rejectedCount orders with status "ditolak"');
      print('========================');

      setState(() {
        _orders = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showCustomDialog(
          title: 'Error!',
          message: 'Gagal memuat daftar pesanan: ${e.toString()}',
          isSuccess: false,
        );
      }
    }
  }

  List<PesananModel> _getFilteredOrders() {
    if (_selectedFilter == 'Semua') {
      return _orders;
    } else {
      return _orders
          .where((order) =>
              _getEffectiveStatus(order).toLowerCase() ==
              _selectedFilter.toLowerCase())
          .toList();
    }
  }

  Future<void> _updateOrderStatus(PesananModel order, String newStatus) async {
    // Show loading dialog
    _showLoadingDialog();

    try {
      final result =
          await _pesananService.updatePesananStatus(order.id, newStatus);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        await _loadAllOrders();
        if (mounted) {
          _showCustomDialog(
            title: 'Berhasil!',
            message: 'Status pesanan berhasil diperbarui ke $newStatus',
            isSuccess: true,
            orderNumber: order.id.toString(),
          );
        }
      } else {
        if (mounted) {
          _showCustomDialog(
            title: 'Gagal!',
            message: result['message'] ?? 'Gagal memperbarui status pesanan',
            isSuccess: false,
            orderNumber: order.id.toString(),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        _showCustomDialog(
          title: 'Error!',
          message: 'Terjadi kesalahan: ${e.toString()}',
          isSuccess: false,
          orderNumber: order.id.toString(),
        );
      }
    }
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required bool isSuccess,
    String? orderNumber,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess ? Colors.green[100] : Colors.red[100],
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    size: 50,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green[700] : Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),

                if (orderNumber != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Order #$orderNumber',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoadingDialog([String? customMessage]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  customMessage ?? 'Processing order...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processOrder(PesananModel order) async {
    // Show loading dialog
    _showLoadingDialog();

    try {
      final result = await _pesananService.processPesanan(order.id);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        await _loadAllOrders();
        if (mounted) {
          _showCustomDialog(
            title: 'Berhasil!',
            message: 'Pesanan berhasil diproses',
            isSuccess: true,
            orderNumber: order.id.toString(),
          );
        }
      } else {
        if (mounted) {
          _showCustomDialog(
            title: 'Gagal!',
            message: result['message'] ?? 'Gagal memproses pesanan',
            isSuccess: false,
            orderNumber: order.id.toString(),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        _showCustomDialog(
          title: 'Error!',
          message: 'Terjadi kesalahan: ${e.toString()}',
          isSuccess: false,
          orderNumber: order.id.toString(),
        );
      }
    }
  }

  Future<void> _tolakPesanan(PesananModel order) async {
    // Show loading dialog
    _showLoadingDialog('Rejecting order...');

    try {
      final result = await _pesananService.tolakPesanan(order.id);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        // Save order ID to rejected list
        await _saveRejectedOrderId(order.id);

        await _loadAllOrders();
        if (mounted) {
          _showCustomDialog(
            title: 'Berhasil!',
            message: 'Pesanan berhasil ditolak',
            isSuccess: true,
            orderNumber: order.id.toString(),
          );
        }
      } else {
        if (mounted) {
          _showCustomDialog(
            title: 'Gagal!',
            message: result['message'] ?? 'Gagal menolak pesanan',
            isSuccess: false,
            orderNumber: order.id.toString(),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        _showCustomDialog(
          title: 'Error!',
          message: 'Terjadi kesalahan: ${e.toString()}',
          isSuccess: false,
          orderNumber: order.id.toString(),
        );
      }
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required Color confirmColor,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: confirmColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: confirmColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Ya, Lanjutkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Order summary stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Orders',
                  _orders.length.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Pending',
                  _orders
                      .where((o) =>
                          _getEffectiveStatus(o).toLowerCase() == 'pending')
                      .length
                      .toString(),
                  Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Completed',
                  _orders
                      .where((o) =>
                          _getEffectiveStatus(o).toLowerCase() == 'completed')
                      .length
                      .toString(),
                  Colors.green,
                ),
              ],
            ),
          ),

          // Second row of stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatCard(
                  'Processing',
                  _orders
                      .where((o) =>
                          _getEffectiveStatus(o).toLowerCase() == 'processing')
                      .length
                      .toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Rejected',
                  _orders
                      .where((o) =>
                          _getEffectiveStatus(o).toLowerCase() == 'rejected')
                      .length
                      .toString(),
                  Colors.red,
                ),
                const SizedBox(width: 10),
                // Empty space for alignment
                Expanded(child: Container()),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersList(filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Semua'
                ? 'There are no orders yet'
                : 'No ${_selectedFilter.toLowerCase()} orders',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<PesananModel> orders) {
    return RefreshIndicator(
      onRefresh: _loadAllOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(PesananModel order) {
    // Format date
    final formattedDate =
        DateFormat('dd MMM yyyy').format(DateTime.parse(order.tanggalPesan));

    // Get status color
    Color statusColor;
    Color statusBgColor;

    switch (_getEffectiveStatus(order)) {
      case 'completed':
      case 'selesai':
        statusColor = Colors.green;
        statusBgColor = Colors.green[50]!;
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue[50]!;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange[50]!;
        break;
      case 'rejected':
      case 'ditolak':
        statusColor = Colors.red;
        statusBgColor = Colors.red[50]!;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusBgColor,
          child: Text(
            '#${order.id}',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getDisplayStatus(order),
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Date: $formattedDate'),
            Text('Customer ID: ${order.userId}'),
            Text('Total: ${_currencyFormat.format(order.calculateTotal())}'),
          ],
        ),
        children: [
          // Order items
          ...order.detail.map((item) => _buildOrderItem(item)).toList(),

          const Divider(height: 24),

          // Order actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (_getEffectiveStatus(order).toLowerCase() == 'pending')
                ElevatedButton.icon(
                  onPressed: () => _showConfirmationDialog(
                    title: 'Process Order',
                    message:
                        'Apakah Anda yakin ingin memproses pesanan #${order.id}?',
                    onConfirm: () => _processOrder(order),
                    confirmColor: Colors.blue,
                    icon: Icons.play_arrow,
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Process'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (_getEffectiveStatus(order).toLowerCase() == 'pending')
                ElevatedButton.icon(
                  onPressed: () => _showConfirmationDialog(
                    title: 'Reject Order',
                    message:
                        'Apakah Anda yakin ingin menolak pesanan #${order.id}? Pesanan yang ditolak tidak dapat diproses kembali.',
                    onConfirm: () => _tolakPesanan(order),
                    confirmColor: Colors.red,
                    icon: Icons.clear,
                  ),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (_getEffectiveStatus(order).toLowerCase() == 'processing')
                ElevatedButton.icon(
                  onPressed: () => _showConfirmationDialog(
                    title: 'Complete Order',
                    message:
                        'Apakah Anda yakin ingin menyelesaikan pesanan #${order.id}?',
                    onConfirm: () => _updateOrderStatus(order, 'completed'),
                    confirmColor: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(PesananDetailModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.getImageUrl() != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.getImageUrl()!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.image, color: Colors.grey),
          ),

          // Product details
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.jumlah} x ${_currencyFormat.format(item.subtotal ~/ item.jumlah)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Item subtotal
          Text(
            _currencyFormat.format(item.subtotal),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
