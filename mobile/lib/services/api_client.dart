/// Central configuration for the API client, maintaining the base server URL
/// and shared headers across all services (e.g., AuthService, EntriesService).
library;
import 'token_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://brought-strewn-repose.ngrok-free.dev/api/v1';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  /// Generates headers for authenticated endpoints.
  static Future<Map<String, String>> authHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      ...jsonHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    };
  }
}

