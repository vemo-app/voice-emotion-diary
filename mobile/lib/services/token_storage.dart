import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages secure storage for authentication tokens using platform-specific 
/// encryption (Keychain for iOS, Keystore for Android) to ensure security.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Checks if a valid token exists in storage.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
