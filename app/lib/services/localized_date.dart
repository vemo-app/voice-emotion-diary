import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'jalali_converter.dart';

class LocalizedDate {
  static String formatNumber(Object input, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      var out = input.toString();
      for (var i = 0; i < western.length; i++) {
        out = out.replaceAll(western[i], persian[i]);
      }
      return out;
    }
    return input.toString();
  }

  static List<String> getWeekdayLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return [
        l10n.weekdaySatShort,
        l10n.weekdaySunShort,
        l10n.weekdayMonShort,
        l10n.weekdayTueShort,
        l10n.weekdayWedShort,
        l10n.weekdayThuShort,
        l10n.weekdayFriShort,
      ];
    } else {
      // English weeks are ordered Sun-Sat (standard Gregorian).
      return [
        l10n.weekdaySunShort,
        l10n.weekdayMonShort,
        l10n.weekdayTueShort,
        l10n.weekdayWedShort,
        l10n.weekdayThuShort,
        l10n.weekdayFriShort,
        l10n.weekdaySatShort,
      ];
    }
  }

  static List<String> getWeekdayFullNames(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return [
        l10n.weekdaySat,
        l10n.weekdaySun,
        l10n.weekdayMon,
        l10n.weekdayTue,
        l10n.weekdayWed,
        l10n.weekdayThu,
        l10n.weekdayFri,
      ];
    } else {
      return [
        l10n.weekdaySun,
        l10n.weekdayMon,
        l10n.weekdayTue,
        l10n.weekdayWed,
        l10n.weekdayThu,
        l10n.weekdayFri,
        l10n.weekdaySat,
      ];
    }
  }

  /// Returns 0-based index for the weekday. 
  /// For FA: 0=Saturday
  /// For EN: 0=Sunday
  static int getWeekdayIndex(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return (date.weekday - 6) % 7;
    } else {
      return date.weekday % 7; // Sunday=0
    }
  }

  static String getMonthName(int month, BuildContext context, {bool isJalali = false}) {
    final l10n = AppLocalizations.of(context)!;
    if (isJalali) {
      final months = [
        l10n.monthFarvardin, l10n.monthOrdibehesht, l10n.monthKhordad,
        l10n.monthTir, l10n.monthMordad, l10n.monthShahrivar,
        l10n.monthMehr, l10n.monthAban, l10n.monthAzar,
        l10n.monthDey, l10n.monthBahman, l10n.monthEsfand,
      ];
      return months[month - 1];
    } else {
      final months = [
        l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
        l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
        l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec,
      ];
      return months[month - 1];
    }
  }

  static String formatFullDate(DateTime date, BuildContext context, {String? jalaliDate}) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'fa' && jalaliDate != null) {
      final parts = jalaliDate.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final day = parts[2];
        final weekday = getWeekdayFullNames(context)[getWeekdayIndex(date, context)];
        return l10n.todayLabel(
          formatNumber(day, context),
          getMonthName(month, context, isJalali: true),
          weekday,
          formatNumber(year, context),
        );
      }
    }

    // Default or English: Gregorian
    final weekday = getWeekdayFullNames(context)[getWeekdayIndex(date, context)];
    return l10n.todayLabel(
      formatNumber(date.day, context),
      getMonthName(date.month, context, isJalali: false),
      weekday,
      formatNumber(date.year, context),
    );
  }

  /// Generates a localized date range for a week. 
  /// Uses the backend-provided Jalali range label for Persian, 
  /// and constructs a Gregorian range for English.
  static String formatDateRange(
    DateTime weekStart,
    DateTime weekEnd,
    BuildContext context, {
    String? jalaliRangeLabel,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa' && jalaliRangeLabel != null) {
      return jalaliRangeLabel;
    }
    final startMonth = getMonthName(weekStart.month, context, isJalali: false);
    final endMonth = getMonthName(weekEnd.month, context, isJalali: false);
    final startDay = formatNumber(weekStart.day, context);
    final endDay = formatNumber(weekEnd.day, context);
    if (weekStart.month == weekEnd.month) {
      return '$startMonth $startDay - $endDay';
    }
    return '$startMonth $startDay - $endMonth $endDay';
  }

  /// Generates a localized label for a Jalali month. 
  /// For English, it calculates the corresponding Gregorian date range.
  static String formatMonthLabel(int jalaliYear, int jalaliMonth, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return '${getMonthName(jalaliMonth, context, isJalali: true)} ${formatNumber(jalaliYear, context)}';
    }
    final range = JalaliConverter.monthGregorianRange(jalaliYear, jalaliMonth);
    final start = range.$1;
    final end = range.$2;
    final startMonth = getMonthName(start.month, context, isJalali: false);
    final endMonth = getMonthName(end.month, context, isJalali: false);
    if (start.month == end.month && start.year == end.year) {
      return '$startMonth ${start.year}';
    }
    if (start.year == end.year) {
      return '$startMonth–$endMonth ${start.year}';
    }
    return '$startMonth ${start.year}–$endMonth ${end.year}';
  }

  /// Returns a short month label for compact UI elements.
  static String formatMonthShortLabel(int jalaliYear, int jalaliMonth, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return getMonthName(jalaliMonth, context, isJalali: true);
    }
    final range = JalaliConverter.monthGregorianRange(jalaliYear, jalaliMonth);
    return getMonthName(range.$1.month, context, isJalali: false);
  }

  /// Returns the localized year label.
  static String formatYearLabel(int jalaliYear, int jalaliMonth, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return formatNumber(jalaliYear, context);
    }
    final range = JalaliConverter.monthGregorianRange(jalaliYear, jalaliMonth);
    return formatNumber(range.$1.year, context);
  }

  static (int year, int month) shiftMonth(int year, int month, int delta) {
    final index = (year * 12 + (month - 1)) + delta;
    return (index ~/ 12, (index % 12) + 1);
  }
}
