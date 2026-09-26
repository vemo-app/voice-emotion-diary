import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'theme_service.dart';
import 'locale_service.dart';
import '../models/user_profile.dart';

class UserException implements Exception {
  final String message;
  UserException(this.message);
}

class UserService {
  /// Syncs theme and language preferences from the backend to the local app state.
  /// This should be called after every successful login to ensure user 
  /// settings are correctly applied. Failures are silently ignored.
  Future<void> syncPreferencesFromBackend() async {
    try {
      final profile = await getMe();
      await ThemeService().setThemeMode(ThemeService.themeModeFromBackend(profile.theme));
      await LocaleService().setLocale(LocaleService.localeFromBackend(profile.language));
    } catch (_) {
      // ignore
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.get(ApiClient.uri(path), headers: headers);
    } catch (_) {
      throw UserException('connectionError');
    }
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw UserException('sessionExpired');
    }
    throw UserException('errorGeneric');
  }

  Future<UserProfile> getMe() async {
    final json = await _get('/users/me');
    return UserProfile.fromJson(json);
  }

  Future<ProfileSummary> getSummary() async {
    final json = await _get('/users/me/summary');
    return ProfileSummary.fromJson(json);
  }

  /// Updates user profile details. Null fields remain unchanged.
  Future<UserProfile> updateMe({String? username, String? email, String? theme, String? language}) async {
    final headers = await ApiClient.authHeaders();
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (theme != null) body['theme'] = theme;
    if (language != null) body['language'] = language;

    final http.Response response;
    try {
      response = await http.patch(
        ApiClient.uri('/users/me'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {
      throw UserException('connectionError');
    }

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    if (response.statusCode == 400) {
      throw UserException('emailAlreadyExists');
    }
    if (response.statusCode == 422) {
      throw UserException('errorNameEmpty');
    }
    if (response.statusCode == 401) {
      throw UserException('sessionExpired');
    }
    throw UserException('errorGeneric');
  }

  /// Changes the user password. Handles invalid current password and weak new passwords.
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.post(
        ApiClient.uri('/users/me/change-password'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode({'current_password': currentPassword, 'new_password': newPassword}),
      );
    } catch (_) {
      throw UserException('connectionError');
    }

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) {
      throw UserException('invalidCredentials');
    }
    if (response.statusCode == 422) {
      throw UserException('passwordShort');
    }
    throw UserException('errorGeneric');
  }

  /// Irreversibly deletes the user account and all associated data.
  Future<void> deleteAccount() async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.delete(ApiClient.uri('/users/me'), headers: headers);
    } catch (_) {
      throw UserException('connectionError');
    }
    if (response.statusCode == 204) return;
    if (response.statusCode == 401) {
      throw UserException('sessionExpired');
    }
    throw UserException('errorDeleteMemory');
  }
}
