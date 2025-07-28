import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasakhir_mobile/models/user_model.dart';
import 'package:tugasakhir_mobile/utils/storage_helper.dart';
import 'package:tugasakhir_mobile/services/api_config.dart';

class AuthService {
  final String _baseUrl = ApiConfig.baseUrl;

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
      print('Register response: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Register berhasil
        final user = UserModel.fromJson(responseData['user']);

        // Cek apakah token ada dalam response
        // Pada beberapa API, register tidak langsung mengembalikan token
        if (responseData.containsKey('token')) {
          final token = responseData['token'];

          // Simpan token dan user data
          await StorageHelper.saveToken(token);
          await StorageHelper.saveUser(jsonEncode(user.toJson()));

          return {'success': true, 'user': user, 'token': token};
        } else {
          // Tidak ada token, hanya simpan data user sementara
          // Pengguna harus login untuk mendapatkan token
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Registrasi berhasil, silakan login',
            'user': user,
          };
        }
      } else {
        // Register gagal - Handle validation errors properly
        Map<String, List<String>> errors = {};
        if (responseData['errors'] != null) {
          final rawErrors = responseData['errors'] as Map<String, dynamic>;
          rawErrors.forEach((key, value) {
            if (value is List) {
              errors[key] = value.map((e) => e.toString()).toList();
            } else {
              errors[key] = [value.toString()];
            }
          });
        }

        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal',
          'errors': errors,
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

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await StorageHelper.getToken();

      if (token != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        // Clear storage regardless of response
        await StorageHelper.clearAll();

        if (response.statusCode == 200) {
          return {'success': true};
        }
      }

      // Clear storage even if no token
      await StorageHelper.clearAll();
      return {'success': true};
    } catch (e) {
      // Clear storage on error too
      await StorageHelper.clearAll();
      return {'success': true};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final url = '$_baseUrl/forgot-password';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = {
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      };

      print('Reset Password Request:');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        return {
          'success': false,
          'message':
              'Server error: Received HTML response instead of JSON. Status: ${response.statusCode}',
        };
      }

      // Check if response body is empty
      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message':
              'Server error: Empty response. Status: ${response.statusCode}',
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password berhasil direset',
        };
      } else {
        // Handle validation errors properly
        Map<String, List<String>> errors = {};
        if (responseData['errors'] != null) {
          final rawErrors = responseData['errors'] as Map<String, dynamic>;
          rawErrors.forEach((key, value) {
            if (value is List) {
              errors[key] = value.map((e) => e.toString()).toList();
            } else {
              errors[key] = [value.toString()];
            }
          });
        }

        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mereset password',
          'errors': errors,
        };
      }
    } catch (e) {
      print('Reset Password Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
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
