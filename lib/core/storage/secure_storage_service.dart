import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String username = 'username';
}

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              wOptions: WindowsOptions(),
              mOptions: MacOsOptions(),
            );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Access Token Helpers
  Future<void> saveAccessToken(String token) async {
    await write(StorageKeys.accessToken, token);
  }

  Future<String?> getAccessToken() async {
    return await read(StorageKeys.accessToken);
  }

  // Refresh Token Helpers
  Future<void> saveRefreshToken(String token) async {
    await write(StorageKeys.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await read(StorageKeys.refreshToken);
  }

  // Role Helpers
  Future<void> saveUserRole(String role) async {
    await write(StorageKeys.userRole, role);
  }

  Future<String?> getUserRole() async {
    return await read(StorageKeys.userRole);
  }

  // Username Helpers
  Future<void> saveUsername(String username) async {
    await write(StorageKeys.username, username);
  }

  Future<String?> getUsername() async {
    return await read(StorageKeys.username);
  }

  // Clear Session
  Future<void> clearSession() async {
    await clearAll();
  }
}
