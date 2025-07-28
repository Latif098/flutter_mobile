import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tugasakhir_mobile/models/produk_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class ProdukService {
  final String _baseUrl = 'http://10.148.46.9:8000/api';

  // Get all products
  Future<Map<String, dynamic>> getAllProduk() async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/produk'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<ProdukModel> produkList =
            data.map((item) => ProdukModel.fromJson(item)).toList();

        return {
          'success': true,
          'data': produkList,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat produk',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Get single product by ID
  Future<Map<String, dynamic>> getProduk(int id) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/produk/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': ProdukModel.fromJson(data),
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Produk tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Create a new product
  Future<Map<String, dynamic>> createProduk({
    required String namaProduk,
    required dynamic harga,
    required dynamic stok,
    required dynamic kategoriProdukId,
    File? gambarProduk,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      // Jika ada gambar, gunakan multipart request
      if (gambarProduk != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/produk'),
        );

        // Tambahkan header
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });

        // Tambahkan field data
        request.fields['nama_produk'] = namaProduk;
        request.fields['harga'] = harga.toString();
        request.fields['stok'] = stok.toString();
        request.fields['kategori_produk_id'] = kategoriProdukId.toString();

        // Tambahkan file gambar
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_produk',
            gambarProduk.path,
          ),
        );

        // Kirim request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Produk berhasil dibuat',
            'data': ProdukModel.fromJson(responseData['data']),
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal membuat produk',
            'errors': responseData['errors'],
          };
        }
      } else {
        // Jika tidak ada gambar, gunakan JSON request biasa
        final response = await http.post(
          Uri.parse('$_baseUrl/produk'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'nama_produk': namaProduk,
            'harga': harga,
            'stok': stok,
            'kategori_produk_id': kategoriProdukId,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Produk berhasil dibuat',
            'data': ProdukModel.fromJson(responseData['data']),
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal membuat produk',
            'errors': responseData['errors'],
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update a product
  Future<Map<String, dynamic>> updateProduk({
    required int id,
    required String namaProduk,
    required dynamic harga,
    required dynamic stok,
    required dynamic kategoriProdukId,
    File? gambarProduk,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      // Jika ada gambar, gunakan multipart request
      if (gambarProduk != null) {
        var request = http.MultipartRequest(
          'POST', // API biasanya menerima PUT melalui _method field
          Uri.parse('$_baseUrl/produk/$id'),
        );

        // Tambahkan header
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });

        // Tambahkan field data
        request.fields['_method'] = 'PUT'; // Simulasi PUT request
        request.fields['nama_produk'] = namaProduk;
        request.fields['harga'] = harga.toString();
        request.fields['stok'] = stok.toString();
        request.fields['kategori_produk_id'] = kategoriProdukId.toString();

        // Tambahkan file gambar
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_produk',
            gambarProduk.path,
          ),
        );

        // Kirim request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Produk berhasil diperbarui',
            'data': responseData['data'] != null
                ? ProdukModel.fromJson(responseData['data'])
                : null,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal memperbarui produk',
            'errors': responseData['errors'],
          };
        }
      } else {
        // Jika tidak ada gambar, gunakan JSON request biasa
        final response = await http.put(
          Uri.parse('$_baseUrl/produk/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'nama_produk': namaProduk,
            'harga': harga,
            'stok': stok,
            'kategori_produk_id': kategoriProdukId,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Produk berhasil diperbarui',
            'data': responseData['data'] != null
                ? ProdukModel.fromJson(responseData['data'])
                : null,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal memperbarui produk',
            'errors': responseData['errors'],
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Delete a product
  Future<Map<String, dynamic>> deleteProduk(int id) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/produk/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Produk berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal menghapus produk',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
