import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasakhir_mobile/models/kategori_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class KategoriService {
  final String _baseUrl = 'http://192.168.137.185:8000/api';

  Future<Map<String, dynamic>> getAllKategori() async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/kategori'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<KategoriModel> kategoriList =
            data.map((item) => KategoriModel.fromJson(item)).toList();

        return {'success': true, 'data': kategoriList};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memuat kategori',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createKategori(String namaKategori) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/kategori'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nama_kategori': namaKategori}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Kategori berhasil dibuat',
          'data': KategoriModel.fromJson(responseData['data']),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal membuat kategori',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteKategori(int id) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/kategori/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Kategori berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal menghapus kategori',
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
