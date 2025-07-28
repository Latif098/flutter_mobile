import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_completed';

  // Menyimpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Mengambil token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Menghapus token (untuk logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Menyimpan data user (sebagai JSON string)
  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  // Mengambil data user
  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  // Menghapus data user
  static Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Menyimpan nilai umum
  static Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Mengambil nilai umum
  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }

  // Menghapus nilai umum
  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }

  // Onboarding methods
  static Future<void> setOnboardingCompleted() async {
    await _storage.write(key: _onboardingKey, value: 'true');
  }

  static Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
