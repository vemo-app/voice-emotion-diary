import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/report_models.dart';

class AnalyticsException implements Exception {
  final String message;
  AnalyticsException(this.message);
}

class AnalyticsService {
  Future<Map<String, dynamic>> _get(String path) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.get(ApiClient.uri(path), headers: headers);
    } catch (_) {
      throw AnalyticsException('connectionError');
    }
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw AnalyticsException('sessionExpired');
    }
    throw AnalyticsException('errorLoadAnalytics');
  }

  Future<MonthlySummary> getMonthlySummary({int? jalaliYear, int? jalaliMonth}) async {
    final query = _monthQuery(jalaliYear, jalaliMonth);
    final json = await _get('/reports/monthly$query');
    return MonthlySummary.fromJson(json);
  }

  Future<List<DailyEmotionPoint>> getMonthlyDays({int? jalaliYear, int? jalaliMonth}) async {
    final query = _monthQuery(jalaliYear, jalaliMonth);
    final json = await _get('/reports/monthly-days$query');
    final days = json['days'] as List;
    return days.map((d) => DailyEmotionPoint.fromJson(d as Map<String, dynamic>)).toList();
  }

  /// Similar to getMonthlyDays, but also returns the actual Jalali year and month used.
  Future<({int jalaliYear, int jalaliMonth, List<DailyEmotionPoint> days})> getMonthlyDaysFull({
    int? jalaliYear,
    int? jalaliMonth,
  }) async {
    final query = _monthQuery(jalaliYear, jalaliMonth);
    final json = await _get('/reports/monthly-days$query');
    final daysJson = json['days'] as List;
    return (
      jalaliYear: json['jalali_year'] as int,
      jalaliMonth: json['jalali_month'] as int,
      days: daysJson.map((d) => DailyEmotionPoint.fromJson(d as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<WeekSummary>> getWeeklyTrend({int weeks = 4}) async {
    final json = await _get('/reports/weekly-trend?weeks=$weeks');
    final list = json['weeks'] as List;
    return list.map((w) => WeekSummary.fromJson(w as Map<String, dynamic>)).toList();
  }

  /// Checks for existing monthly insights. Returns null if not found (404).
  Future<(String, String)?> getMonthlyInsight({int? jalaliYear, int? jalaliMonth}) async {
    final headers = await ApiClient.authHeaders();
    final query = _monthQuery(jalaliYear, jalaliMonth);
    final http.Response response;
    try {
      response = await http.get(ApiClient.uri('/reports/monthly-insight$query'), headers: headers);
    } catch (_) {
      throw AnalyticsException('connectionError');
    }
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (json['insight'] as String, json['insight'] as String);
    }
    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode == 401) {
      throw AnalyticsException('sessionExpired');
    }
    throw AnalyticsException('errorCheckInsight');
  }

  /// Manually triggers generation of a monthly insight via LLM.
  Future<(String, String)> requestMonthlyInsight({int? jalaliYear, int? jalaliMonth}) async {
    final headers = await ApiClient.authHeaders();
    final query = _monthQuery(jalaliYear, jalaliMonth);
    final http.Response response;
    try {
      response = await http.post(ApiClient.uri('/reports/monthly-insight$query'), headers: headers);
    } catch (_) {
      throw AnalyticsException('connectionError');
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (json['insight'] as String, json['insight'] as String);
    }
    if (response.statusCode == 401) {
      throw AnalyticsException('sessionExpired');
    }
    throw AnalyticsException('errorGenerateInsight');
  }

  String _monthQuery(int? jalaliYear, int? jalaliMonth) {
    if (jalaliYear == null || jalaliMonth == null) return '';
    return '?jalali_year=$jalaliYear&jalali_month=$jalaliMonth';
  }

  // ---------------- Weekly ----------------

  Future<WeeklyReport> getWeeklyReport({DateTime? forDate}) async {
    final json = await _get('/reports/weekly${_dateQuery(forDate)}');
    return WeeklyReport.fromJson(json);
  }

  /// Checks for existing weekly insights. Does not trigger LLM generation.
  Future<String?> getWeeklyInsight({DateTime? forDate}) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.get(
        ApiClient.uri('/reports/weekly-insight${_dateQuery(forDate)}'),
        headers: headers,
      );
    } catch (_) {
      throw AnalyticsException('connectionError');
    }
    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return json['insight'] as String;
    }
    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode == 401) {
      throw AnalyticsException('sessionExpired');
    }
    throw AnalyticsException('errorCheckInsight');
  }

  /// Manually triggers generation of a weekly insight.
  Future<String> requestWeeklyInsight({DateTime? forDate}) async {
    final headers = await ApiClient.authHeaders();
    final http.Response response;
    try {
      response = await http.post(
        ApiClient.uri('/reports/weekly-insight/generate${_dateQuery(forDate)}'),
        headers: headers,
      );
    } catch (_) {
      throw AnalyticsException('connectionError');
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return json['insight'] as String;
    }
    if (response.statusCode == 409) {
      throw AnalyticsException('errorNoNotesThisWeek');
    }
    if (response.statusCode == 401) {
      throw AnalyticsException('sessionExpired');
    }
    throw AnalyticsException('errorGenerateInsight');
  }

  String _dateQuery(DateTime? forDate) {
    if (forDate == null) return '';
    final d =
        '${forDate.year}-${forDate.month.toString().padLeft(2, '0')}-${forDate.day.toString().padLeft(2, '0')}';
    return '?for_date=$d';
  }
}
