import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/memory_entry.dart';

class EntriesException implements Exception {
  final String message;
  EntriesException(this.message);
}

class EntriesService {
  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Fetches memories recorded on a specific date.
  Future<List<MemoryEntry>> getEntriesForDate(DateTime date) async {
    final headers = await ApiClient.authHeaders();
    final dateStr = _dateStr(date);

    final http.Response response;
    try {
      response = await http.get(
        ApiClient.uri('/voice-notes?for_date=$dateStr'),
        headers: headers,
      );
    } catch (_) {
      throw EntriesException('connectionError');
    }

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => MemoryEntry.fromApi(e as Map<String, dynamic>))
          .toList();
    }
    if (response.statusCode == 401) {
      throw EntriesException('sessionExpired');
    }
    throw EntriesException('errorFetchEntries');
  }

  /// Fetches memories recorded today.
  Future<List<MemoryEntry>> getTodayEntries() => getEntriesForDate(DateTime.now());

  /// Fetches the daily report for the emotion chart. Defaults to today.
  Future<Map<String, dynamic>> getDailyReport({DateTime? forDate}) async {
    final headers = await ApiClient.authHeaders();
    final query = forDate != null ? '?for_date=${_dateStr(forDate)}' : '';
    final http.Response response;
    try {
      response = await http.get(ApiClient.uri('/reports/daily$query'), headers: headers);
    } catch (_) {
      throw EntriesException('connectionError');
    }

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw EntriesException('sessionExpired');
    }
    throw EntriesException('errorFetchDailyReport');
  }
}