/// A single day from the day-by-day breakdown (for the monthly heat-grid -
/// no jalali_date included).
class DailyEmotionPoint {
  final DateTime date;
  final int notesCount;
  final Map<String, double> emotions; // anger/happiness/sadness/neutral

  DailyEmotionPoint({
    required this.date,
    required this.notesCount,
    required this.emotions,
  });

  factory DailyEmotionPoint.fromJson(Map<String, dynamic> json) {
    return DailyEmotionPoint(
      date: DateTime.parse(json['date'] as String),
      notesCount: json['notes_count'] as int,
      emotions: {
        'anger': (json['anger'] as num).toDouble(),
        'happiness': (json['happiness'] as num).toDouble(),
        'sadness': (json['sadness'] as num).toDouble(),
        'neutral': (json['neutral'] as num).toDouble(),
      },
    );
  }
}

/// A single day from the weekly view; includes jalali_date (used for the
/// day label).
class WeeklyDayPoint {
  final DateTime date;
  final String jalaliDate; // e.g. "1404-05-14"
  final int notesCount;
  final Map<String, double> emotions;

  WeeklyDayPoint({
    required this.date,
    required this.jalaliDate,
    required this.notesCount,
    required this.emotions,
  });

  factory WeeklyDayPoint.fromJson(Map<String, dynamic> json) {
    return WeeklyDayPoint(
      date: DateTime.parse(json['date'] as String),
      jalaliDate: json['jalali_date'] as String,
      notesCount: json['notes_count'] as int,
      emotions: {
        'anger': (json['anger'] as num).toDouble(),
        'happiness': (json['happiness'] as num).toDouble(),
        'sadness': (json['sadness'] as num).toDouble(),
        'neutral': (json['neutral'] as num).toDouble(),
      },
    );
  }
}

/// Full response of GET /reports/weekly
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final String rangeLabel; // e.g. "10-16 Mordad"
  final List<WeeklyDayPoint> days;

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.rangeLabel,
    required this.days,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as List;
    return WeeklyReport(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      rangeLabel: json['range_label'] as String,
      days: daysJson.map((d) => WeeklyDayPoint.fromJson(d as Map<String, dynamic>)).toList(),
    );
  }
}

class WeekSummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int notesCount;
  final Map<String, double> emotions;

  WeekSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.notesCount,
    required this.emotions,
  });

  factory WeekSummary.fromJson(Map<String, dynamic> json) {
    return WeekSummary(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      notesCount: json['notes_count'] as int,
      emotions: {
        'anger': (json['anger'] as num).toDouble(),
        'happiness': (json['happiness'] as num).toDouble(),
        'sadness': (json['sadness'] as num).toDouble(),
        'neutral': (json['neutral'] as num).toDouble(),
      },
    );
  }
}

class MonthlySummary {
  final int jalaliYear;
  final int jalaliMonth;
  final String monthName;
  final int notesCount;
  final Map<String, double> emotions;

  MonthlySummary({
    required this.jalaliYear,
    required this.jalaliMonth,
    required this.monthName,
    required this.notesCount,
    required this.emotions,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      jalaliYear: json['jalali_year'] as int,
      jalaliMonth: json['jalali_month'] as int,
      monthName: json['month_name'] as String,
      notesCount: json['notes_count'] as int,
      emotions: {
        'anger': (json['anger'] as num).toDouble(),
        'happiness': (json['happiness'] as num).toDouble(),
        'sadness': (json['sadness'] as num).toDouble(),
        'neutral': (json['neutral'] as num).toDouble(),
      },
    );
  }
}
