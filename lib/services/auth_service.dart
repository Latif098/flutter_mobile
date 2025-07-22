import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';

class AuthService {
  final String _baseUrl = 'http://192.168.137.185:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Login berhasil
      final user = UserModel.fromJson(responseData['user']);
      final token = responseData['token'];

      // Simpan token dan user data
      await StorageHelper.saveToken(token);
      await StorageHelper.saveUser(jsonEncode(user.toJson()));

      return {'success': true, 'user': user, 'token': token};
    } else {
      // Login gagal
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login gagal',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Register berhasil
        final user = UserModel.fromJson(responseData['user']);
        final token = responseData['token'];

        // Simpan token dan user data
        await StorageHelper.saveToken(token);
        await StorageHelper.saveUser(jsonEncode(user.toJson()));

        return {'success': true, 'user': user, 'token': token};
      } else {
        // Register gagal
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('Register error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  Future<bool> logout() async {
    try {
      // Menghapus token dan user data dari storage
      await StorageHelper.deleteToken();
      await StorageHelper.deleteUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    return await StorageHelper.isLoggedIn();
  }

  Future<int?> getUserRole() async {
    final userJson = await StorageHelper.getUser();
    if (userJson != null) {
      final user = UserModel.fromJson(jsonDecode(userJson));
      return user.roleId;
    }
    return null;
  }
}
