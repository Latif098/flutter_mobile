import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasakhir_mobile/models/cart_item_model.dart';
import 'package:tugasakhir_mobile/models/pesanan_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class PesananService {
  final String _baseUrl = 'http://10.148.46.9:8000/api';

  Future<Map<String, dynamic>> createPesanan(List<CartItemModel> items) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Anda belum login',
        };
      }

      // Format data pesanan sesuai dengan API
      final pesananData = {
        'items': items
            .map((item) => {
                  'produk_id': item.id,
                  'jumlah': item.quantity,
                  'subtotal': item.harga * item.quantity,
                })
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/pesanan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(pesananData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        PesananModel pesanan = PesananModel.fromJson(responseData['data']);

        return {
          'success': true,
          'message': 'Pesanan berhasil dibuat',
          'data': pesanan,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal membuat pesanan',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  Future<List<PesananModel>> getPesananList() async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/pesanan'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PesananModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting pesanan list: ${e.toString()}');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPesananDetail(int pesananId) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Anda belum login',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/pesanan/$pesananId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pesanan = PesananModel.fromJson(data);

        return {
          'success': true,
          'data': pesanan,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Gagal mendapatkan detail pesanan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  // Get all orders (for admin)
  Future<List<PesananModel>> getAllOrders() async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/pesanan-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PesananModel.fromJson(item)).toList();
      } else {
        print('Error fetching all orders: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception fetching all orders: ${e.toString()}');
      return [];
    }
  }

  Future<Map<String, dynamic>> updatePesananStatus(
      int pesananId, String status) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Anda belum login',
        };
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/pesanan/$pesananId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Status pesanan berhasil diperbarui',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Gagal memperbarui status pesanan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }
}
