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

  // Rejected Order IDs management
  static const String _rejectedOrderIdsKey = 'rejected_order_ids';

  static Future<void> saveRejectedOrderIds(List<int> orderIds) async {
    final idsJson = orderIds.map((id) => id.toString()).join(',');
    await _storage.write(key: _rejectedOrderIdsKey, value: idsJson);
  }

  static Future<List<int>> getRejectedOrderIds() async {
    final idsJson = await _storage.read(key: _rejectedOrderIdsKey);
    if (idsJson == null || idsJson.isEmpty) {
      return [];
    }
    return idsJson
        .split(',')
        .map((id) => int.tryParse(id) ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  static Future<void> addRejectedOrderId(int orderId) async {
    final currentIds = await getRejectedOrderIds();
    if (!currentIds.contains(orderId)) {
      currentIds.add(orderId);
      await saveRejectedOrderIds(currentIds);
    }
  }

  static Future<void> removeRejectedOrderId(int orderId) async {
    final currentIds = await getRejectedOrderIds();
    currentIds.remove(orderId);
    await saveRejectedOrderIds(currentIds);
  }
}
