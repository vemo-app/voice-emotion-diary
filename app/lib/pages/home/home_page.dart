import 'package:flutter/material.dart';
import '../../models/emotion.dart';
import '../../models/memory_entry.dart';
import '../../services/entries_service.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../widgets/home/emotion_chart_card.dart';
import '../../widgets/home/memory_card.dart';
import '../ai_feedback/ai_feedback_page.dart';
import '../new_memory/new_memory_page.dart';
import '../analystics/analystics.dart';
import '../history/history_calendar_page.dart';
import '../history/edit_memory_page.dart';
import '../profile/profile_page.dart';
import '../../services/voice_note_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localized_date.dart';

String _persianDigits(Object input, BuildContext context) {
  return LocalizedDate.formatNumber(input, context);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  final _entriesService = EntriesService();
  final _voiceNoteService = VoiceNoteService();

  bool _loading = true;
  String? _error;
  List<EmotionChartItem> _chartItems = [];
  List<MemoryEntry> _memories = [];
  Map<String, dynamic>? _dailyReport;

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
      final report = await _entriesService.getDailyReport();
      final entries = await _entriesService.getTodayEntries();

      setState(() {
        _memories = entries;
        _chartItems = _buildChartItems(report);
        _dailyReport = report;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error'; // Will be localized in build
        _loading = false;
      });
    }
  }

  /// Generates a localized date label (e.g., "Tuesday, August 5, 2025")
  /// using the jalali_date from the backend report, as Flutter doesn't
  /// natively support Jalali date conversion.
  String _getTodayLabel(BuildContext context, Map<String, dynamic> report) {
    return LocalizedDate.formatFullDate(
      DateTime.now(),
      context,
      jalaliDate: report['jalali_date'] as String?,
    );
  }

  EmotionType? _dominantOf(Map<String, dynamic> report) {
    if (_memories.isEmpty) return null;
    final values = {
      EmotionType.happy: (report['happiness'] as num).toDouble(),
      EmotionType.sad: (report['sadness'] as num).toDouble(),
      EmotionType.anger: (report['anger'] as num).toDouble(),
      EmotionType.neutral: (report['neutral'] as num).toDouble(),
    };
    // If no memories have been processed/analyzed yet (e.g., newly recorded
    // and still processing), the sum of all values is zero. Null is returned
    // instead of incorrectly picking the first item as dominant.
    final total = values.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return null;
    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
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
        barFraction: fraction.clamp(0.05, 1.0), // Minimum height for visibility
      );
    }).toList();
  }

  void _handleNavTap(int index) {
    if (index == 1) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HistoryCalendarPage()),
        (route) => false,
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AnalyticsPage()),
        (route) => false,
      );
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
        (route) => false,
      );
      return;
    }
    setState(() => _navIndex = index);
  }

  Future<void> _handleRecordNewMemory() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NewMemoryPage()),
    );
    if (saved == true) {
      _loadData();
    }
  }

  Future<void> _handleEditMemory(MemoryEntry entry) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditMemoryPage(entry: entry)),
    );
    if (changed == true) _loadData();
  }

  void _handleFeedbackTap(MemoryEntry entry) {
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

  Future<void> _handleDeleteMemory(MemoryEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.deleteMemoryTitle),
        content: Text(l10n.deleteMemoryConfirmation(entry.title)),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _voiceNoteService.deleteVoiceNote(entry.id);
      _loadData();
    } on VoiceNoteException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String msg = l10n.errorGeneric;
      if (e.message == 'connectionError') msg = l10n.connectionError;
      if (e.message == 'sessionExpired') msg = l10n.sessionExpired;
      if (e.message == 'errorMemoryNotFound') msg = l10n.errorMemoryNotFound;
      if (e.message == 'errorDeleteMemory') msg = l10n.errorDeleteMemory;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        // Placing BottomNav in this slot (rather than inside the body Stack)
        // ensures it stays fixed at the bottom and doesn't scroll with content.
        bottomNavigationBar: BottomNav(
          currentIndex: _navIndex,
          onTap: _handleNavTap,
        ),
        body: SafeArea(
          bottom: false, // Bottom padding is handled by the BottomNav widget.
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.errorLoading, textAlign: TextAlign.center, style: context.pwHint.copyWith(color: Colors.red)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _loadData, child: Text(l10n.tryAgain)),
                          ],
                        ),
                      ),
                    )
                  : Stack(
            children: [
              // Main scrollable content: Date + Chart + Memory Entries
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(_getTodayLabel(context, _dailyReport!),
                              style: context.greetDate),
                          const SizedBox(height: 16),
                          EmotionChartCard(
                            title: l10n.emotionChartTitle,
                            subtitle: l10n.emotionChartSubtitle(_persianDigits(_memories.length, context)),
                            badgeText: () {
                              final dominant = _dailyReport != null ? _dominantOf(_dailyReport!) : null;
                              return dominant != null
                                  ? l10n.dominantEmotionLabel(dominant.label(context))
                                  : '—';
                            }(),
                            items: _chartItems,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.homeTitle,
                                  style: context.sectionTitle),
                              Text(l10n.memoriesCount(_persianDigits(_memories.length, context)),
                                  style: context.sectionCount),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    sliver: _memories.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(l10n.noMemoriesToday, style: context.pwHint.copyWith(fontSize: 13)),
                              ),
                            ),
                          )
                        : SliverList.builder(
                      itemCount: _memories.length,
                      itemBuilder: (context, index) {
                        final entry = _memories[index];
                        return MemoryCard(
                          entry: entry,
                          onEdit: () => _handleEditMemory(entry),
                          onDelete: () => _handleDeleteMemory(entry),
                          onFeedbackTap: () => _handleFeedbackTap(entry),
                        );
                      },
                    ),
                  ),
                ],
              ),

              Positioned(
                left: 20,
                right: 20,
                bottom: 14,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: _handleRecordNewMemory,
                    child: Ink(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: context.colors.shadowFab,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎙', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Text(l10n.recordNewMemory, style: context.fabText),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}