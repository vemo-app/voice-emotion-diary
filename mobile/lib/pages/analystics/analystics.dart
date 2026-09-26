import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/report_models.dart';
import '../../services/analytics_service.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../ai_feedback/ai_feedback_page.dart';
import '../history/history_calendar_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localized_date.dart';

const _emotionOrder = ['happiness', 'sadness', 'anger', 'neutral'];

Map<String, Color> _getEmotionBarColors(BuildContext context) => {
  'happiness': context.colors.happyBar,
  'sadness': context.colors.sadBar,
  'anger': context.colors.angerBar,
  'neutral': context.colors.neutralBar,
};

String _persianDigits(Object input, BuildContext context) {
  return LocalizedDate.formatNumber(input, context);
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _service = AnalyticsService();

  int _tabIndex = 1; // 0 = Weekly, 1 = Monthly (default)
  bool _loading = true;
  String? _error;

  MonthlySummary? _monthly;
  List<DailyEmotionPoint> _monthDays = [];
  List<WeekSummary> _weeklyTrend = [];
  DateTime? _selectedDay;

  (String, String)? _insight;
  bool _insightChecked = false; // Whether the initial GET request for insights is complete

  // ---- Weekly Tab ----
  WeeklyReport? _weeklyReport;
  DateTime? _selectedWeekDay;

  String? _weeklyInsight;
  bool _weeklyInsightChecked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getMonthlySummary(),
        _service.getMonthlyDays(),
        _service.getWeeklyTrend(),
        _service.getWeeklyReport(),
      ]);
      final monthDays = results[1] as List<DailyEmotionPoint>;
      final weeklyReport = results[3] as WeeklyReport;
      final today = DateTime.now();
      final todayMatch = monthDays.where(
            (d) => d.date.year == today.year && d.date.month == today.month && d.date.day == today.day,
      );
      final todayInWeek = weeklyReport.days.where(
            (d) => d.date.year == today.year && d.date.month == today.month && d.date.day == today.day,
      );

      setState(() {
        _monthly = results[0] as MonthlySummary;
        _monthDays = monthDays;
        _weeklyTrend = results[2] as List<WeekSummary>;
        _selectedDay = todayMatch.isNotEmpty ? todayMatch.first.date : (monthDays.isNotEmpty ? monthDays.last.date : null);
        _weeklyReport = weeklyReport;
        _selectedWeekDay = todayInWeek.isNotEmpty
            ? todayInWeek.first.date
            : (weeklyReport.days.isNotEmpty ? weeklyReport.days.last.date : null);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error'; // Localized in build
        _loading = false;
      });
      return;
    }
    _checkInsight();
    _checkWeeklyInsight();
  }

  Future<void> _checkInsight() async {
    try {
      final result = await _service.getMonthlyInsight();
      if (!mounted) return;
      setState(() {
        _insight = result;
        _insightChecked = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _insightChecked = true);
    }
  }

  Future<void> _checkWeeklyInsight() async {
    try {
      final result = await _service.getWeeklyInsight();
      if (!mounted) return;
      setState(() {
        _weeklyInsight = result;
        _weeklyInsightChecked = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _weeklyInsightChecked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: BottomNav(
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HistoryCalendarPage()),
                (route) => false,
              );
            } else if (index == 3) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
                (route) => false,
              );
            }
          },
        ),
        body: SafeArea(
          bottom: false,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(l10n.errorLoadAnalytics, style: context.pwHint.copyWith(color: Colors.red)))
              : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(l10n.analyticsTitle,
                      style: context.sectionTitle.copyWith(fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(l10n.analyticsSubtitle, style: context.pwHint.copyWith(fontSize: 12.5)),
                  const SizedBox(height: 18),
                  _buildTabs(context, l10n),
                  const SizedBox(height: 16),
                  if (_tabIndex == 1) ..._buildMonthlyTabContent(context, l10n) else ..._buildWeeklyTabContent(context, l10n),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildTabs(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: context.colors.line, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _tabItem(context, l10n.weekly, 0),
          _tabItem(context, l10n.monthly, 1),
        ],
      ),
    );
  }

  Widget _tabItem(BuildContext context, String label, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? context.colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive ? context.colors.shadowSoft : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.pwHint.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.blue700 : context.colors.ink400,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMonthlyTabContent(BuildContext context, AppLocalizations l10n) {
    return [
      _buildMonthlyStatRow(context, l10n),
      const SizedBox(height: 16),
      _buildMonthlyCard(context, l10n),
      const SizedBox(height: 16),
      _buildWeeklyTrendCard(context, l10n),
      const SizedBox(height: 16),
      _buildInsightCard(context, l10n),
    ];
  }

  List<Widget> _buildWeeklyTabContent(BuildContext context, AppLocalizations l10n) {
    return [
      _buildWeeklyStatRow(context, l10n),
      const SizedBox(height: 16),
      _buildWeeklyCard(context, l10n),
      const SizedBox(height: 16),
      _buildWeeklyInsightCard(context, l10n),
    ];
  }

  Widget _buildMonthlyStatRow(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(16), boxShadow: context.colors.shadowSoft),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(_persianDigits('${_monthly?.notesCount ?? 0}', context),
              style: context.sectionTitle.copyWith(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(l10n.memoriesCount(_persianDigits('${_monthly?.notesCount ?? 0}', context)), style: context.pwHint.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Map<String, double> _weeklyTotals(WeeklyReport report) {
    final totalNotes = report.days.fold<int>(0, (s, d) => s + d.notesCount);
    if (totalNotes == 0) {
      return {for (final k in _emotionOrder) k: 0.0};
    }
    return {
      for (final k in _emotionOrder)
        k: report.days.fold<double>(0, (s, d) => s + (d.emotions[k] ?? 0) * d.notesCount) / totalNotes,
    };
  }

  Widget _buildWeeklyStatRow(BuildContext context, AppLocalizations l10n) {
    final report = _weeklyReport;
    final totalNotes = report?.days.fold<int>(0, (s, d) => s + d.notesCount) ?? 0;

    final emotionLabels = {
      'happiness': l10n.happiness,
      'sadness': l10n.sadness,
      'anger': l10n.anger,
      'neutral': l10n.neutral,
    };

    String dominantLabel = '—';
    String dominantPct = l10n.percent(_persianDigits('0', context));
    if (report != null && totalNotes > 0) {
      final totals = _weeklyTotals(report);
      final totalSum = totals.values.fold<double>(0, (a, b) => a + b);
      if (totalSum > 0) {
        final dominant = totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
        dominantLabel = l10n.dominantEmotionLabel(emotionLabels[dominant.key]!);
        dominantPct = l10n.percent(_persianDigits((dominant.value * 100).round().toString(), context));
      }
    }

    return Row(
      children: [
        Expanded(child: _statBox(context, _persianDigits('$totalNotes', context), l10n.memoriesCount('$totalNotes'))),
        const SizedBox(width: 12),
        Expanded(child: _statBox(context, dominantPct, dominantLabel)),
      ],
    );
  }

  Widget _statBox(BuildContext context, String number, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(16), boxShadow: context.colors.shadowSoft),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(number, style: context.sectionTitle.copyWith(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: context.pwHint.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMonthlyCard(BuildContext context, AppLocalizations l10n) {
    final monthly = _monthly!;
    final title = LocalizedDate.formatMonthLabel(monthly.jalaliYear, monthly.jalaliMonth, context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(20), boxShadow: context.colors.shadowSoft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.monthlyOverview, style: context.memoryTitle.copyWith(fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(title, style: context.pwHint.copyWith(fontSize: 11.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(100)),
                child: Text(l10n.thisMonth, style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.purple700)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildDonutRow(context, monthly, l10n),
          const SizedBox(height: 18),
          _buildWeekdayRow(context, l10n),
          const SizedBox(height: 8),
          _buildHeatGrid(context, l10n),
          if (_selectedDayPoint != null) _buildDayDetail(context, _selectedDayPoint!, _selectedJalaliDay ?? 0, l10n),
          _buildMonthLegend(context, l10n),
        ],
      ),
    );
  }

  DailyEmotionPoint? get _selectedDayPoint {
    if (_selectedDay == null) return null;
    final matches = _monthDays.where(
          (d) => d.date.year == _selectedDay!.year && d.date.month == _selectedDay!.month && d.date.day == _selectedDay!.day,
    );
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Backend returns days in the exact order of the Jalali month (1 to N).
  /// Position in list (index + 1) is the Jalali day number.
  int? get _selectedJalaliDay {
    if (_selectedDay == null) return null;
    final idx = _monthDays.indexWhere(
          (d) => d.date.year == _selectedDay!.year && d.date.month == _selectedDay!.month && d.date.day == _selectedDay!.day,
    );
    return idx == -1 ? null : idx + 1;
  }

  Widget _buildDonutRow(BuildContext context, MonthlySummary monthly, AppLocalizations l10n) {
    final total = _emotionOrder.fold<double>(0, (sum, key) => sum + (monthly.emotions[key] ?? 0));
    final barColors = _getEmotionBarColors(context);
    final emotionLabels = {
      'happiness': l10n.happiness,
      'sadness': l10n.sadness,
      'anger': l10n.anger,
      'neutral': l10n.neutral,
    };

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.line))),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(92, 92),
                  painter: _DonutPainter(monthly.emotions, total, barColors),
                ),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(color: context.colors.surface, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_persianDigits(monthly.notesCount, context), style: context.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(l10n.memoriesCount(''), style: context.pwHint.copyWith(fontSize: 8.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: _emotionOrder.map((key) {
                final value = monthly.emotions[key] ?? 0;
                final pct = total == 0 ? 0 : (value / total * 100).round();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: barColors[key], shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(emotionLabels[key]!, style: context.pwHint.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.ink600)),
                        ],
                      ),
                      Text(l10n.percent(_persianDigits('$pct', context)), style: context.sectionTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w800)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(BuildContext context, AppLocalizations l10n) {
    final labels = LocalizedDate.getWeekdayLabels(context);
    return Row(
      children: labels
          .map((l) => Expanded(child: Center(child: Text(l, style: context.pwHint.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)))))
          .toList(),
    );
  }

  int _weekdayIndex(DateTime d, BuildContext context) => LocalizedDate.getWeekdayIndex(d, context);

  Widget _buildHeatGrid(BuildContext context, AppLocalizations l10n) {
    if (_monthDays.isEmpty) return const SizedBox.shrink();
    final leading = _weekdayIndex(_monthDays.first.date, context);
    final totalCells = leading + _monthDays.length;
    final trailing = (7 - (totalCells % 7)) % 7;
    final today = DateTime.now();

    final cells = <Widget>[
      ...List.generate(leading, (_) => const SizedBox.shrink()),
      ..._monthDays.asMap().entries.map((entry) {
        final jalaliDay = entry.key + 1;
        final day = entry.value;
        final isFuture = day.date.isAfter(DateTime(today.year, today.month, today.day));
        final isSelected = _selectedDay != null &&
            day.date.year == _selectedDay!.year &&
            day.date.month == _selectedDay!.month &&
            day.date.day == _selectedDay!.day;
        return _heatCell(context, day, jalaliDay: jalaliDay, isFuture: isFuture, isSelected: isSelected);
      }),
      ...List.generate(trailing, (_) => const SizedBox.shrink()),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: cells,
    );
  }

  Widget _heatCell(BuildContext context, DailyEmotionPoint day, {required int jalaliDay, required bool isFuture, required bool isSelected}) {
    final barColors = _getEmotionBarColors(context);
    return GestureDetector(
      onTap: isFuture ? null : () => setState(() => _selectedDay = day.date),
      child: Container(
        padding: const EdgeInsets.fromLTRB(3, 4, 3, 3),
        decoration: BoxDecoration(
          color: isFuture ? context.colors.line.withValues(alpha: 0.55) : context.colors.line,
          borderRadius: BorderRadius.circular(9),
          border: isSelected ? Border.all(color: AppColors.blue900, width: 2.5) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_persianDigits('${Localizations.localeOf(context).languageCode == 'fa' ? jalaliDay : day.date.day}', context), style: context.pwHint.copyWith(fontSize: 8.5, fontWeight: FontWeight.w700)),
            if (!isFuture && day.notesCount > 0) ...[
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _emotionOrder.map((key) {
                    final total = _emotionOrder.fold<double>(0, (s, k) => s + (day.emotions[k] ?? 0));
                    final frac = total == 0 ? 0.0 : (day.emotions[key] ?? 0) / total;
                    return Container(
                      width: 4,
                      height: max(2, frac * 20),
                      margin: const EdgeInsets.symmetric(horizontal: 0.75),
                      decoration: BoxDecoration(color: barColors[key], borderRadius: BorderRadius.circular(2)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetail(BuildContext context, DailyEmotionPoint day, int jalaliDay, AppLocalizations l10n) {
    final total = _emotionOrder.fold<double>(0, (s, k) => s + (day.emotions[k] ?? 0));
    final emojiFor = {'happiness': l10n.happinessEmoji, 'sadness': l10n.sadnessEmoji, 'anger': l10n.angerEmoji, 'neutral': l10n.neutralEmoji};
    final barColors = _getEmotionBarColors(context);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dayDetail(_persianDigits('${Localizations.localeOf(context).languageCode == 'fa' ? jalaliDay : day.date.day}', context)), style: context.memoryTitle.copyWith(fontSize: 13.5)),
          Text(l10n.memoriesCount(_persianDigits('${day.notesCount}', context)), style: context.pwHint.copyWith(fontSize: 11)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _emotionOrder.map((key) {
              final value = day.emotions[key] ?? 0;
              final pct = total == 0 ? 0 : (value / total * 100).round();
              final frac = total == 0 ? 0.0 : value / total;
              return Expanded(
                child: Column(
                  children: [
                    Text(l10n.percent(_persianDigits('$pct', context)), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _emotionFg(context, key))),
                    const SizedBox(height: 7),
                    Container(
                      width: 26,
                      height: 56,
                      decoration: BoxDecoration(color: context.colors.line, borderRadius: BorderRadius.circular(100)),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 26,
                        height: max(4, frac * 56),
                        decoration: BoxDecoration(color: barColors[key], borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(emojiFor[key]!, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _emotionFg(BuildContext context, String key) {
    switch (key) {
      case 'happiness':
        return context.colors.happyFg;
      case 'sadness':
        return context.colors.sadFg;
      case 'anger':
        return context.colors.angerFg;
      default:
        return context.colors.neutralFg;
    }
  }

  Widget _buildMonthLegend(BuildContext context, AppLocalizations l10n) {
    final barColors = _getEmotionBarColors(context);
    final emotionLabels = {
      'happiness': l10n.happiness,
      'sadness': l10n.sadness,
      'anger': l10n.anger,
      'neutral': l10n.neutral,
    };

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.line))),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 8,
        children: _emotionOrder.map((key) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: barColors[key], shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(emotionLabels[key]!, style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.ink600)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ---------------- Weekly Emotion Chart (Weekly Tab) ----------------

  Widget _buildWeeklyCard(BuildContext context, AppLocalizations l10n) {
    final report = _weeklyReport;
    if (report == null || report.days.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(20), boxShadow: context.colors.shadowSoft),
        alignment: Alignment.center,
        child: Text(l10n.noMemoriesRecorded, style: context.pwHint),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(20), boxShadow: context.colors.shadowSoft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.weeklyEmotionChart, style: context.memoryTitle.copyWith(fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(
                    LocalizedDate.formatDateRange(
                      report.weekStart,
                      report.weekEnd,
                      context,
                      jalaliRangeLabel: report.rangeLabel,
                    ),
                    style: context.pwHint.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(100)),
                child: Text(l10n.thisWeek, style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.purple700)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildWeekChart(context, report, l10n),
          if (_selectedWeekDayPoint != null) _buildWeekDayDetail(context, _selectedWeekDayPoint!, l10n),
        ],
      ),
    );
  }

  WeeklyDayPoint? get _selectedWeekDayPoint {
    final report = _weeklyReport;
    if (report == null || _selectedWeekDay == null) return null;
    final matches = report.days.where(
          (d) => d.date.year == _selectedWeekDay!.year && d.date.month == _selectedWeekDay!.month && d.date.day == _selectedWeekDay!.day,
    );
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Backend returns days starting from Saturday. For English locales,
  /// the list is rotated to start from Sunday instead.
  List<WeeklyDayPoint> _localizedWeekOrder(List<WeeklyDayPoint> days, BuildContext context) {
    if (days.length != 7) return days;
    final locale = Localizations.localeOf(context).languageCode;
    final startWeekday = locale == 'fa' ? DateTime.saturday : DateTime.sunday;
    final startIndex = days.indexWhere((d) => d.date.weekday == startWeekday);
    if (startIndex <= 0) return days;
    return [...days.sublist(startIndex), ...days.sublist(0, startIndex)];
  }

  Widget _buildWeekChart(BuildContext context, WeeklyReport report, AppLocalizations l10n) {
    final orderedDays = _localizedWeekOrder(report.days, context);
    final maxTotal = orderedDays
        .map((d) => _emotionOrder.fold<double>(0, (s, k) => s + (d.emotions[k] ?? 0)))
        .fold<double>(0.001, (a, b) => a > b ? a : b);
    final today = DateTime.now();
    final barColors = _getEmotionBarColors(context);
    final weekdayLabels = LocalizedDate.getWeekdayLabels(context);

    return Container(
      height: 150,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(orderedDays.length, (i) {
          final day = orderedDays[i];
          final total = _emotionOrder.fold<double>(0, (s, k) => s + (day.emotions[k] ?? 0));
          final isEmpty = day.notesCount == 0;
          final isFuture = day.date.isAfter(DateTime(today.year, today.month, today.day));
          final isSelected = _selectedWeekDay != null &&
              day.date.year == _selectedWeekDay!.year &&
              day.date.month == _selectedWeekDay!.month &&
              day.date.day == _selectedWeekDay!.day;
          final barHeight = isEmpty ? 40.0 : 40 + (total / maxTotal) * 70;

          return Expanded(
            child: GestureDetector(
              onTap: isFuture ? null : () => setState(() => _selectedWeekDay = day.date),
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: barHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: AppColors.blue700, width: 2.5) : null,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: isEmpty
                        ? Container(color: context.colors.neutralBar.withValues(alpha: 0.4))
                        : Column(
                      verticalDirection: VerticalDirection.up,
                      children: _emotionOrder.map((key) {
                        final value = day.emotions[key] ?? 0;
                        final frac = total == 0 ? 0.0 : value / total;
                        return Expanded(
                          flex: (frac * 1000).round().clamp(1, 1000),
                          child: Container(color: barColors[key]),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weekdayLabels[LocalizedDate.getWeekdayIndex(day.date, context)],
                    style: context.pwHint.copyWith(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.blue700 : context.colors.ink600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeekDayDetail(BuildContext context, WeeklyDayPoint day, AppLocalizations l10n) {
    final total = _emotionOrder.fold<double>(0, (s, k) => s + (day.emotions[k] ?? 0));
    final emojiFor = {'happiness': l10n.happinessEmoji, 'sadness': l10n.sadnessEmoji, 'anger': l10n.angerEmoji, 'neutral': l10n.neutralEmoji};
    final weekdayIndex = LocalizedDate.getWeekdayIndex(day.date, context);
    final weekdayFullNames = LocalizedDate.getWeekdayFullNames(context);
    final barColors = _getEmotionBarColors(context);

    String dateLabel = LocalizedDate.formatFullDate(day.date, context, jalaliDate: day.jalaliDate);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dayDetail(weekdayFullNames[weekdayIndex]), style: context.memoryTitle.copyWith(fontSize: 13.5)),
          Text(
            '$dateLabel · ${l10n.memoriesCount(_persianDigits('${day.notesCount}', context))}',
            style: context.pwHint.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),
          if (day.notesCount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.noMemoriesToday, style: context.pwHint.copyWith(fontSize: 12)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _emotionOrder.map((key) {
                final value = day.emotions[key] ?? 0;
                final pct = total == 0 ? 0 : (value / total * 100).round();
                final frac = total == 0 ? 0.0 : value / total;
                return Expanded(
                  child: Column(
                    children: [
                      Text(l10n.percent(_persianDigits('$pct', context)), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _emotionFg(context, key))),
                      const SizedBox(height: 7),
                      Container(
                        width: 26,
                        height: 56,
                        decoration: BoxDecoration(color: context.colors.line, borderRadius: BorderRadius.circular(100)),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 26,
                          height: max(4, frac * 56),
                          decoration: BoxDecoration(color: barColors[key], borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(emojiFor[key]!, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------- Weekly AI insight card ----------------

  Widget _buildWeeklyInsightCard(BuildContext context, AppLocalizations l10n) {
    if (!_weeklyInsightChecked) return const SizedBox.shrink();
    final periodLabel = _weeklyReport != null
        ? LocalizedDate.formatDateRange(
            _weeklyReport!.weekStart,
            _weeklyReport!.weekEnd,
            context,
            jalaliRangeLabel: _weeklyReport!.rangeLabel,
          )
        : '';

    if (_weeklyInsight != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AiFeedbackPage(
                detailText: _weeklyInsight!,
                periodLabel: periodLabel,
                pageTitle: l10n.aiFeedback,
                cardSubtitle: l10n.weeklyOverview,
              ),
            ),
          );
        },
        child: _insightCardShell(
          context,
          title: l10n.aiFeedback,
          body: _weeklyInsight!,
          trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 20,
              color: context.colors.ink400),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AiFeedbackPage(
              loader: () => _service.requestWeeklyInsight(),
              periodLabel: periodLabel,
              pageTitle: l10n.aiFeedback,
              cardSubtitle: l10n.weeklyOverview,
            ),
          ),
        );
      },
      child: _insightCardShell(
        context,
        title: l10n.aiFeedback,
        body: l10n.getWeeklyInsight,
        trailing: const Icon(Icons.auto_awesome, size: 18, color: AppColors.purple700),
      ),
    );
  }

  // ---------------- Week-over-week trend ----------------

  Widget _buildWeeklyTrendCard(BuildContext context, AppLocalizations l10n) {
    if (_weeklyTrend.isEmpty) return const SizedBox.shrink();
    final maxTotal = _weeklyTrend
        .map((w) => _emotionOrder.fold<double>(0, (s, k) => s + (w.emotions[k] ?? 0)))
        .fold<double>(0.001, (a, b) => a > b ? a : b);
    final barColors = _getEmotionBarColors(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(20), boxShadow: context.colors.shadowSoft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.weeklyTrend, style: context.memoryTitle.copyWith(fontSize: 14.5)),
                  Text(l10n.compareLast4Weeks, style: context.pwHint.copyWith(fontSize: 11.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(100)),
                child: Text(l10n.weeksCount(_persianDigits('${_weeklyTrend.length}', context)), style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.purple700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_weeklyTrend.length, (i) {
              final week = _weeklyTrend[i];
              final total = _emotionOrder.fold<double>(0, (s, k) => s + (week.emotions[k] ?? 0));
              final isLast = i == _weeklyTrend.length - 1;
              final barHeight = 30 + (total / maxTotal) * 60;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: isLast ? Border.all(color: AppColors.blue700, width: 2.5) : null,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        verticalDirection: VerticalDirection.up,
                        children: _emotionOrder.map((key) {
                          final value = week.emotions[key] ?? 0;
                          final frac = total == 0 ? 0.0 : value / total;
                          return Expanded(
                            flex: (frac * 1000).round().clamp(1, 1000),
                            child: Container(color: barColors[key]),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Week ${_persianDigits(i + 1, context)}',
                      style: context.pwHint.copyWith(
                        fontSize: 11,
                        fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                        color: isLast ? AppColors.blue700 : context.colors.ink600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------- AI insight card ----------------

  Widget _buildInsightCard(BuildContext context, AppLocalizations l10n) {
    if (!_insightChecked) return const SizedBox.shrink();
    final periodLabel = _monthly != null
        ? LocalizedDate.formatMonthLabel(_monthly!.jalaliYear, _monthly!.jalaliMonth, context)
        : '';

    if (_insight != null) {
      final (short, detail) = _insight!;
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AiFeedbackPage(
                detailText: detail,
                periodLabel: periodLabel,
                pageTitle: l10n.aiFeedback,
                cardSubtitle: l10n.monthlyOverview,
              ),
            ),
          );
        },
        child: _insightCardShell(
          context,
          title: l10n.aiFeedback,
          body: short,
          trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 20,
              color: context.colors.ink400),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AiFeedbackPage(
              loader: () async {
                final (_, detail) = await _service.requestMonthlyInsight();
                return detail;
              },
              periodLabel: periodLabel,
              pageTitle: l10n.aiFeedback,
              cardSubtitle: l10n.monthlyOverview,
            ),
          ),
        );
      },
      child: _insightCardShell(
        context,
        title: l10n.aiFeedback,
        body: l10n.getMonthlyInsight,
        trailing: const Icon(Icons.auto_awesome, size: 18, color: AppColors.purple700),
      ),
    );
  }

  Widget _insightCardShell(BuildContext context, {required String title, required String body, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: context.colors.insightGradient),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(13)),
            alignment: Alignment.center,
            child: const Text('✨', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.memoryTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: context.pwHint.copyWith(fontSize: 11.5, color: context.colors.ink600, height: 1.6),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> emotions;
  final double total;
  final Map<String, Color> barColors;

  _DonutPainter(this.emotions, this.total, this.barColors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var startAngle = -pi / 2;
    const strokeWidth = 18.0;

    for (final key in _emotionOrder) {
      final value = emotions[key] ?? 0;
      final sweep = total == 0 ? 0.0 : (value / total) * 2 * pi;
      final paint = Paint()
        ..color = barColors[key]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.emotions != emotions || oldDelegate.total != total || oldDelegate.barColors != barColors;
  }
}
