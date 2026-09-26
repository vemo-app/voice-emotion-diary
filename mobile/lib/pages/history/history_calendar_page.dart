import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/report_models.dart';
import '../../models/emotion.dart';
import '../../services/analytics_service.dart';
import '../../services/entries_service.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../widgets/home/emotion_chart_card.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../analystics/analystics.dart';
import '../home/home_page.dart';
import 'day_entries_page.dart';
import '../profile/profile_page.dart';
import '../../l10n/app_localizations.dart';

import '../../services/localized_date.dart';

const _emotionOrder = ['happiness', 'sadness', 'anger', 'neutral'];

String _persianDigits(Object input, BuildContext context) {
  return LocalizedDate.formatNumber(input, context);
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

(int, int) _shiftJalaliMonth(int year, int month, int delta) {
  final index = (year * 12 + (month - 1)) + delta;
  return (index ~/ 12, (index % 12) + 1);
}

class HistoryCalendarPage extends StatefulWidget {
  const HistoryCalendarPage({super.key});

  @override
  State<HistoryCalendarPage> createState() => _HistoryCalendarPageState();
}

class _HistoryCalendarPageState extends State<HistoryCalendarPage> {
  final _service = AnalyticsService();
  bool _loading = true;
  String? _error;
  int _jalaliYear = 0;
  int _jalaliMonth = 0;
  List<DailyEmotionPoint> _days = [];
  MonthlySummary? _monthlySummary;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({int? jalaliYear, int? jalaliMonth}) async {
    setState(() { _loading = true; _error = null; });
    try {
      // If year/month are not provided (initial load), the current Jalali month
      // is determined from the daily report instead of letting the backend guess,
      // ensuring consistency across the app.
      var effectiveYear = jalaliYear;
      var effectiveMonth = jalaliMonth;
      if (effectiveYear == null || effectiveMonth == null) {
        final todayReport = await EntriesService().getDailyReport(forDate: DateTime.now());
        final parts = (todayReport['jalali_date'] as String).split('-');
        effectiveYear = int.parse(parts[0]);
        effectiveMonth = int.parse(parts[1]);
      }
      final current = await _service.getMonthlyDaysFull(jalaliYear: effectiveYear, jalaliMonth: effectiveMonth);
      final y = current.jalaliYear;
      final m = current.jalaliMonth;
      // Monthly summary for the selected year and month, used for the chart displayed above the calendar.
      final summary = await _service.getMonthlySummary(jalaliYear: y, jalaliMonth: m);
      final today = DateTime.now();
      final todayMatch = current.days.where((d) => _isSameDay(d.date, today));
      if (!mounted) return;
      setState(() {
        _jalaliYear = y; _jalaliMonth = m;
        _days = current.days;
        _monthlySummary = summary;
        _selectedDate ??= todayMatch.isNotEmpty ? todayMatch.first.date : null;
        _loading = false;
      });
    } on AnalyticsException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String msg = l10n.errorLoadCalendar;
      if (e.message == 'connectionError') msg = l10n.connectionError;
      if (e.message == 'sessionExpired') msg = l10n.sessionExpired;
      setState(() { _error = msg; _loading = false; });
    } on EntriesException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String msg = l10n.errorLoadCalendar;
      if (e.message == 'connectionError') msg = l10n.connectionError;
      if (e.message == 'sessionExpired') msg = l10n.sessionExpired;
      setState(() { _error = msg; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = AppLocalizations.of(context)!.errorLoadCalendar; _loading = false; });
    }
  }

  void _goToMonth(int year, int month) {
    setState(() => _selectedDate = null);
    _loadData(jalaliYear: year, jalaliMonth: month);
  }

  void _shiftMonth(int delta) {
    final (y, m) = _shiftJalaliMonth(_jalaliYear, _jalaliMonth, delta);
    _goToMonth(y, m);
  }



  DailyEmotionPoint? get _selectedDayPoint {
    if (_selectedDate == null) return null;
    final matches = _days.where((d) => _isSameDay(d.date, _selectedDate!));
    return matches.isNotEmpty ? matches.first : null;
  }

  String? _dominantEmotion(Map<String, double> emotions) {
    final total = _emotionOrder.fold<double>(0, (s, k) => s + (emotions[k] ?? 0));
    if (total == 0) return null;
    return _emotionOrder.reduce((a, b) => (emotions[a] ?? 0) >= (emotions[b] ?? 0) ? a : b);
  }

  Map<String, Color> _getEmotionBarColors() => {
    'happiness': context.colors.happyBar,
    'sadness': context.colors.sadBar,
    'anger': context.colors.angerBar,
    'neutral': context.colors.neutralBar,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: BottomNav(currentIndex: 1, onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          } else if (i == 2) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AnalyticsPage()),
              (route) => false,
            );
          } else if (i == 3) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
              (route) => false,
            );
          }
        }),
        body: SafeArea(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text(l10n.errorLoading)) : RefreshIndicator(
          onRefresh: () => _loadData(jalaliYear: _jalaliYear, jalaliMonth: _jalaliMonth),
          child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6), Text(l10n.historyTitle, style: context.sectionTitle.copyWith(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4), Text(l10n.historySubtitle, style: context.pwHint.copyWith(fontSize: 12.5)),
            const SizedBox(height: 16), _buildSelectorRow(l10n),
            const SizedBox(height: 16), _buildMonthScroll(l10n),
            const SizedBox(height: 18), _buildMonthChart(l10n),
            const SizedBox(height: 18), _buildCalendarCard(l10n),
            if (_selectedDate != null) _buildOpenDayCard(l10n),
          ])),
        )),
      );
  }

  /// Builds the cumulative emotion chart for the selected month using the `_days` data.
  /// This allows users to view statistics for any month in history.
  Widget _buildMonthChart(AppLocalizations l10n) {
    final totals = <String, double>{'happiness': 0, 'sadness': 0, 'anger': 0, 'neutral': 0};
    var notesTotal = 0;
    for (final d in _days) {
      notesTotal += d.notesCount;
      for (final k in totals.keys) {
        totals[k] = totals[k]! + (d.emotions[k] ?? 0);
      }
    }
    final valuesByEmotion = {
      EmotionType.happy: totals['happiness']!,
      EmotionType.sad: totals['sadness']!,
      EmotionType.anger: totals['anger']!,
      EmotionType.neutral: totals['neutral']!,
    };
    final sum = valuesByEmotion.values.fold<double>(0, (a, b) => a + b);
    final maxVal = valuesByEmotion.values.fold<double>(0, (a, b) => a > b ? a : b);

    EmotionType? dominant;
    if (sum > 0) {
      dominant = valuesByEmotion.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    final items = valuesByEmotion.entries.map((e) {
      final fraction = maxVal == 0 ? 0.0 : e.value / maxVal;
      final pct = sum == 0 ? 0 : (e.value / sum * 100).round();
      return EmotionChartItem(
        emotion: e.key,
        percentLabel: l10n.percent(_persianDigits(pct, context)),
        barFraction: fraction.clamp(0.05, 1.0),
      );
    }).toList();

    return EmotionChartCard(
      title: l10n.monthEmotionChartTitle,
      subtitle: l10n.emotionChartSubtitle(_persianDigits(notesTotal, context)),
      badgeText: dominant != null ? l10n.dominantEmotionLabel(dominant.label(context)) : '—',
      items: items,
    );
  }

  Widget _buildSelectorRow(AppLocalizations l10n) {
    return Row(children: [
      Expanded(child: _selectChip(label: l10n.year, value: LocalizedDate.formatYearLabel(_jalaliYear, _jalaliMonth, context), onTap: () async {
        final years = List.generate(7, (i) => _jalaliYear - 5 + i);
        final p = await showModalBottomSheet<int>(context: context, backgroundColor: context.colors.surface, builder: (_) => _PickerSheet(title: l10n.selectYear, items: years, labelBuilder: (y) => LocalizedDate.formatYearLabel(y, _jalaliMonth, context), isSelected: (y) => y == _jalaliYear));
        if (p != null) _goToMonth(p, _jalaliMonth);
      })),
      const SizedBox(width: 10),
      Expanded(child: _selectChip(label: l10n.month, value: LocalizedDate.formatMonthShortLabel(_jalaliYear, _jalaliMonth, context), onTap: () async {
        final p = await showModalBottomSheet<int>(context: context, backgroundColor: context.colors.surface, builder: (_) => _PickerSheet(title: l10n.selectMonth, items: List.generate(12, (i) => i + 1), labelBuilder: (m) => LocalizedDate.formatMonthShortLabel(_jalaliYear, m, context), isSelected: (m) => m == _jalaliMonth));
        if (p != null) _goToMonth(_jalaliYear, p);
      })),
    ]);
  }

  Widget _selectChip({required String label, required String value, required VoidCallback onTap}) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(14), boxShadow: context.colors.shadowSoft), child: Row(children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: context.pwHint.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600)), const SizedBox(height: 1), Text(value, style: context.memoryTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w700))]),
    const Spacer(), const Icon(Icons.expand_more, size: 16, color: AppColors.purple700),
  ])));

  Widget _buildMonthScroll(AppLocalizations l10n) {
    return SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 12, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, i) {
      final month = i + 1; final isActive = month == _jalaliMonth;
      return GestureDetector(onTap: () => _goToMonth(_jalaliYear, month), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), decoration: BoxDecoration(gradient: isActive ? AppColors.heroGradient : null, color: isActive ? null : context.colors.surface, borderRadius: BorderRadius.circular(100), boxShadow: context.colors.shadowSoft), alignment: Alignment.center, child: Text(LocalizedDate.formatMonthShortLabel(_jalaliYear, month, context), style: context.pwHint.copyWith(fontSize: 12.5, fontWeight: isActive ? FontWeight.w700 : FontWeight.w600, color: isActive ? Colors.white : context.colors.ink600))));
    }));
  }

  Widget _buildCalendarCard(AppLocalizations l10n) {
    final weekdayLabels = LocalizedDate.getWeekdayLabels(context);
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(20), boxShadow: context.colors.shadowSoft), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _calArrow(icon: Icons.chevron_right, onTap: () => _shiftMonth(-1)),
        Text(LocalizedDate.formatMonthLabel(_jalaliYear, _jalaliMonth, context), style: context.memoryTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
        _calArrow(icon: Icons.chevron_left, onTap: () => _shiftMonth(1)),
      ]),
      const SizedBox(height: 16),
      Row(children: weekdayLabels.map((l) => Expanded(child: Center(child: Text(l, style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w700))))).toList()),
      const SizedBox(height: 8),
      _buildGrid(l10n), _buildLegend(l10n),
    ]));
  }

  Widget _calArrow({required IconData icon, required VoidCallback onTap}) => GestureDetector(onTap: onTap, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Icon(icon, size: 18, color: context.colors.ink600)));

  Widget _buildGrid(AppLocalizations l10n) {
    if (_days.isEmpty) return const SizedBox.shrink();
    final leading = LocalizedDate.getWeekdayIndex(_days.first.date, context);
    final trailing = (7 - ((leading + _days.length) % 7)) % 7;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final barColors = _getEmotionBarColors();
    final cells = <Widget>[
      ...List.generate(leading, (i) => _mutedCell('')),
      ..._days.asMap().entries.map((entry) {
        final jalaliDay = entry.key + 1; // Backend returns days in chronological order (Jalali 1 to N).
        final day = entry.value;
        // Display Jalali day number for Persian locale, and Gregorian day number for other locales.
        final locale = Localizations.localeOf(context).languageCode;
        final displayDay = locale == 'fa' ? jalaliDay : day.date.day;
        final isFuture = day.date.isAfter(todayOnly);
        final isSelected = _selectedDate != null && _isSameDay(day.date, _selectedDate!);
        final dominant = _dominantEmotion(day.emotions);
        return _dayCell(label: _persianDigits(displayDay, context), dotColor: dominant != null ? barColors[dominant] : null, isMuted: isFuture, isToday: _isSameDay(day.date, todayOnly), isSelected: isSelected, onTap: isFuture ? null : () => setState(() => _selectedDate = day.date));
      }),
      ...List.generate(trailing, (i) => _mutedCell('')),
    ];
    return GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 6, childAspectRatio: 1.05, children: cells);
  }

  Widget _mutedCell(String label) => Container(height: 46, alignment: Alignment.center, child: Text(_persianDigits(label, context), style: context.pwHint.copyWith(fontSize: 12.5, color: context.colors.ink400.withValues(alpha: 0.5))));

  Widget _dayCell({required String label, Color? dotColor, required bool isMuted, required bool isToday, required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap, child: Container(height: 46, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(gradient: isSelected ? AppColors.heroGradient : null, color: isSelected ? null : (isToday ? AppColors.blue100 : Colors.transparent), borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(fontSize: 12.5, fontFamily: Localizations.localeOf(context).languageCode == 'fa' ? GoogleFonts.vazirmatn().fontFamily : GoogleFonts.inter().fontFamily, fontWeight: (isToday || isSelected) ? FontWeight.w800 : FontWeight.w600, color: isSelected ? Colors.white : isToday ? AppColors.blue700 : isMuted ? context.colors.ink400.withValues(alpha: 0.5) : context.colors.ink900)),
      if (!isMuted && dotColor != null) ...[const SizedBox(height: 4), Container(width: 5, height: 5, decoration: BoxDecoration(color: isSelected ? Colors.white : dotColor, shape: BoxShape.circle))],
    ])));
  }

  Widget _buildLegend(AppLocalizations l10n) {
    final barColors = _getEmotionBarColors();
    final emotionLabels = {
      'happiness': l10n.happiness,
      'sadness': l10n.sadness,
      'anger': l10n.anger,
      'neutral': l10n.neutral,
    };
    return Container(margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.only(top: 14), decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.line))), child: Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 8, children: _emotionOrder.map((key) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: barColors[key], shape: BoxShape.circle)),
      const SizedBox(width: 5), Text(emotionLabels[key]!, style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.ink600)),
    ])).toList()));
  }

  Widget _buildOpenDayCard(AppLocalizations l10n) {
    final point = _selectedDayPoint; final selected = _selectedDate!;
    final indexInMonth = _days.indexWhere((d) => _isSameDay(d.date, selected));
    
    final emotionLabels = {
      'happiness': l10n.happiness,
      'sadness': l10n.sadness,
      'anger': l10n.anger,
      'neutral': l10n.neutral,
    };
    final emojiFor = {'happiness': l10n.happinessEmoji, 'sadness': l10n.sadnessEmoji, 'anger': l10n.angerEmoji, 'neutral': l10n.neutralEmoji};

    final String? constructJalali = Localizations.localeOf(context).languageCode == 'fa'
        ? '$_jalaliYear-$_jalaliMonth-${indexInMonth + 1}'
        : null;

    final title = LocalizedDate.formatFullDate(selected, context, jalaliDate: constructJalali);
    final hasEntries = point != null && point.notesCount > 0;
    final dominant = hasEntries ? _dominantEmotion(point.emotions) : null;
    final emoji = dominant != null ? emojiFor[dominant]! : '📝';
    final desc = hasEntries ? '${l10n.memoriesCount(_persianDigits(point.notesCount, context))} · ${l10n.dominantEmotionLabel(emotionLabels[dominant]!)}' : l10n.noMemoriesThisDay;
    return Container(margin: const EdgeInsets.only(top: 18), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), decoration: BoxDecoration(gradient: LinearGradient(colors: context.colors.insightGradient), borderRadius: BorderRadius.circular(18)), child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(14), boxShadow: context.colors.shadowSoft), alignment: Alignment.center, child: Text(emoji, style: const TextStyle(fontSize: 21))),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.memoryTitle.copyWith(fontSize: 13.5)), const SizedBox(height: 2), Text(desc, style: context.pwHint.copyWith(fontSize: 11.5, color: context.colors.ink600))])),
      if (hasEntries) GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayEntriesPage(date: selected))), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(100)), child: Row(children: [Text(l10n.view, style: context.pwHint.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)), Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right, size: 14, color: Colors.white)]))),
    ]));
  }
}

class _PickerSheet<T> extends StatelessWidget {
  final String title; final List<T> items; final String Function(T) labelBuilder; final bool Function(T) isSelected;
  const _PickerSheet({required this.title, required this.items, required this.labelBuilder, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: context.sectionTitle.copyWith(fontSize: 15)),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, children: items.map((item) {
        final active = isSelected(item);
        return GestureDetector(onTap: () => Navigator.of(context).pop(item), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(gradient: active ? AppColors.heroGradient : null, color: active ? null : context.colors.background, borderRadius: BorderRadius.circular(100)), child: Text(labelBuilder(item), style: context.pwHint.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : context.colors.ink600))));
      }).toList()),
    ])));
  }
}
