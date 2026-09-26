import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'token_storage.dart';

/// Custom exception type so the UI can catch AuthException specifically
/// and show a localized, user-friendly message instead of a raw error.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  /// Logs the user in and persists the token on success.
  /// Token storage is handled here rather than in the UI layer to keep
  /// responsibilities separated.
  Future<void> login({required String email, required String password}) async {
    final http.Response response;
    try {
      response = await http.post(
        ApiClient.uri('/auth/login'),
        headers: ApiClient.jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (_) {
      // Network-level failure (no connection, server unreachable, etc.),
      // as opposed to a logical failure like wrong credentials.
      throw AuthException('connectionError');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await TokenStorage.saveToken(data['access_token'] as String);
      return;
    }

    if (response.statusCode == 401) {
      throw AuthException('invalidCredentials');
    }

    throw AuthException('errorGeneric');
  }

  /// Registers a new user and persists the token on success.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await http.post(
        ApiClient.uri('/auth/register'),
        headers: ApiClient.jsonHeaders,
        body: jsonEncode({'username': name, 'email': email, 'password': password}),
      );
    } catch (_) {
      throw AuthException('connectionError');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await TokenStorage.saveToken(data['access_token'] as String);
      return;
    }

    if (response.statusCode == 409) {
      throw AuthException('emailAlreadyExists');
    }

    throw AuthException('errorGeneric');
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}
