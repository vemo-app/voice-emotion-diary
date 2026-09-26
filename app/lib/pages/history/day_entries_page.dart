import 'package:flutter/material.dart';
import '../../models/emotion.dart';
import '../../models/memory_entry.dart';
import '../../services/entries_service.dart';
import '../../services/voice_note_service.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../widgets/home/emotion_chart_card.dart';
import '../ai_feedback/ai_feedback_page.dart';
import 'edit_memory_page.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localized_date.dart';

String _persianDigits(Object input, BuildContext context) {
  return LocalizedDate.formatNumber(input, context);
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;



/// View for a specific day: includes the average emotion chart for that day
/// and a list of recorded memories. Accessible via the calendar "View Day" button.
class DayEntriesPage extends StatefulWidget {
  final DateTime date; // Gregorian date for the target day

  const DayEntriesPage({super.key, required this.date});

  @override
  State<DayEntriesPage> createState() => _DayEntriesPageState();
}

class _DayEntriesPageState extends State<DayEntriesPage> {
  final _service = EntriesService();
  final _voiceNoteService = VoiceNoteService();

  late DateTime _date;
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _report;
  List<MemoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _date = widget.date;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report = await _service.getDailyReport(forDate: _date);
      final entries = await _service.getEntriesForDate(_date);
      if (!mounted) return;
      setState(() {
        _report = report;
        _entries = entries;
        _loading = false;
      });
    } on EntriesException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String msg = l10n.errorGeneric;
      if (e.message == 'connectionError') msg = l10n.connectionError;
      if (e.message == 'sessionExpired') msg = l10n.sessionExpired;
      if (e.message == 'errorFetchEntries') msg = l10n.errorFetchEntries;
      if (e.message == 'errorFetchDailyReport') msg = l10n.errorFetchDailyReport;
      setState(() {
        _error = msg;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.errorGeneric;
        _loading = false;
      });
    }
  }

  void _jumpToToday() {
    final today = DateTime.now();
    if (_isSameDay(_date, today)) return;
    setState(() => _date = today);
    _loadData();
  }

  List<EmotionChartItem> _buildChartItems(Map<String, dynamic> report) {
    final l10n = AppLocalizations.of(context)!;
    final values = {
      EmotionType.happy: (report['happiness'] as num).toDouble(),
      EmotionType.sad: (report['sadness'] as num).toDouble(),
      EmotionType.anger: (report['anger'] as num).toDouble(),
      EmotionType.neutral: (report['neutral'] as num).toDouble(),
    };
    final maxVal = values.values.fold<double>(0, (a, b) => a > b ? a : b);

    return values.entries.map((e) {
      final fraction = maxVal == 0 ? 0.0 : e.value / maxVal;
      final pct = (e.value * 100).round();
      return EmotionChartItem(
        emotion: e.key,
        percentLabel: l10n.percent(_persianDigits(pct, context)),
        barFraction: fraction.clamp(0.05, 1.0),
      );
    }).toList();
  }

  EmotionType? _dominantOf(Map<String, dynamic> report) {
    final values = {
      EmotionType.happy: (report['happiness'] as num).toDouble(),
      EmotionType.sad: (report['sadness'] as num).toDouble(),
      EmotionType.anger: (report['anger'] as num).toDouble(),
      EmotionType.neutral: (report['neutral'] as num).toDouble(),
    };
    if ((report['notes_count'] as int) == 0) return null;
    // If a memory exists but processing/analysis is incomplete, the sum of all values
    // is zero. We return null to avoid incorrectly identifying a dominant emotion.
    final total = values.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return null;
    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void _showFeedbackSheet(MemoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiFeedbackPage(
          loader: () => _voiceNoteService.requestFeedback(entry.id),
          periodLabel: entry.title,
          pageTitle: l10n.aiFeedback,
          cardSubtitle: entry.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopbar(l10n),
              if (!_loading && _error == null && _report != null) _buildChartWrap(l10n),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!, style: context.pwHint.copyWith(color: Colors.red)))
                    : _buildList(context, l10n),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildTopbar(AppLocalizations l10n) {
    String title = '';
    if (_report != null) {
      title = LocalizedDate.formatFullDate(_date, context, jalaliDate: _report!['jalali_date'] as String?);
    }
    final count = _report != null ? _report!['notes_count'] as int : _entries.length;
    final subtitle = count > 0 ? l10n.memoriesRecordedThisDay(_persianDigits(count, context)) : l10n.noMemoriesThisDay;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(11), boxShadow: context.colors.shadowSoft),
              alignment: Alignment.center,
              child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  size: 20,
                  color: context.colors.ink900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.isEmpty ? ' ' : title,
                    style: context.memoryTitle.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: context.pwHint.copyWith(fontSize: 11.5)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _jumpToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.purple100, borderRadius: BorderRadius.circular(100)),
              child: Text(l10n.today, style: context.pwHint.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.purple700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartWrap(AppLocalizations l10n) {
    final report = _report!;
    final count = report['notes_count'] as int;
    final dominant = _dominantOf(report);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: EmotionChartCard(
        title: l10n.emotionChartDay,
        subtitle: count > 0 ? l10n.averageEmotionAcross(_persianDigits(count, context)) : l10n.noMemoriesThisDay,
        badgeText: dominant != null ? l10n.dominantEmotionLabel(dominant.label(context)) : '—',
        items: _buildChartItems(report),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppLocalizations l10n) {
    if (_entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.noMemoriesThisDay, style: context.pwHint.copyWith(fontSize: 13)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 2, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.memoriesThisDay, style: context.sectionTitle),
                Text(l10n.memoriesCount(_persianDigits(_entries.length, context)), style: context.sectionCount),
              ],
            ),
          ),
          ..._entries.map((e) => _buildMemoryRow(context, e, l10n)),
        ],
      ),
    );
  }

  Widget _buildMemoryRow(BuildContext context, MemoryEntry entry, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => EditMemoryPage(entry: entry)),
        );
        if (changed == true) _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(18), boxShadow: context.colors.shadowSoft),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: entry.dominantEmotion.bg(context), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Text(entry.dominantEmotion.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: context.memoryTitle.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(LocalizedDate.formatNumber(entry.timeLabel, context), style: context.memoryMeta.copyWith(fontSize: 11.5)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildMiniBars(context, entry, l10n),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _showFeedbackSheet(entry),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple500, AppColors.blue700]),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: const [BoxShadow(color: Color(0x477C4DFF), blurRadius: 10, offset: Offset(0, 4))],
                ),
                alignment: Alignment.center,
                child: const Text('✦', style: TextStyle(fontSize: 13, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBars(BuildContext context, MemoryEntry entry, AppLocalizations l10n) {
    const maxHeight = 26.0;
    final emotionLabels = {
      EmotionType.happy: l10n.happiness,
      EmotionType.sad: l10n.sadness,
      EmotionType.anger: l10n.anger,
      EmotionType.neutral: l10n.neutral,
    };
    return SizedBox(
      height: maxHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: EmotionType.values.map((emotion) {
          final fraction = entry.emotionMix[emotion] ?? 0;
          // Tooltip displays the exact percentage of each emotion on long press.
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Tooltip(
              message: '${emotionLabels[emotion]}: ${l10n.percent(_persianDigits((fraction * 100).round(), context))}',
              triggerMode: TooltipTriggerMode.longPress,
              child: Container(
                width: 4.5,
                height: (maxHeight * fraction.clamp(0.0, 1.0)).clamp(2.0, maxHeight),
                decoration: BoxDecoration(color: emotion.bar(context), borderRadius: BorderRadius.circular(3)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}