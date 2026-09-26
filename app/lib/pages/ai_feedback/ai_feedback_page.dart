import 'package:flutter/material.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../services/voice_note_service.dart';
import '../../services/entries_service.dart';
import '../../services/analytics_service.dart';

class AiFeedbackPage extends StatefulWidget {
  final String? detailText;
  final Future<String> Function()? loader;
  final String periodLabel;
  final String pageTitle;
  final String cardSubtitle;

  const AiFeedbackPage({
    super.key,
    this.detailText,
    this.loader,
    required this.periodLabel,
    this.pageTitle = 'AI Feedback',
    this.cardSubtitle = 'Full Analysis',
  }) : assert(detailText != null || loader != null, 'Either detailText or loader must be provided');

  @override
  State<AiFeedbackPage> createState() => _AiFeedbackPageState();
}

class _AiFeedbackPageState extends State<AiFeedbackPage> {
  String? _text;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.detailText != null) {
      _text = widget.detailText;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.loader!();
      if (!mounted) return;
      setState(() {
        _text = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _localizedErrorMessage(e);
        _loading = false;
      });
    }
  }

  /// This widget's loaders call several different services (VoiceNoteService,
  /// AnalyticsService, etc.), each of which throws its own exception type.
  /// All of them carry a neutral string key rather than a full sentence.
  /// This maps that key - regardless of which exception it came from - to a
  /// localized message. If the key is unrecognized or the error isn't one of
  /// these known exception types, fall back to a generic localized
  /// message instead of showing the raw `e.toString()`.
  String _localizedErrorMessage(Object e) {
    final l10n = AppLocalizations.of(context)!;
    String? key;
    if (e is VoiceNoteException) key = e.message;
    if (e is EntriesException) key = e.message;
    if (e is AnalyticsException) key = e.message;

    switch (key) {
      case 'connectionError':
        return l10n.connectionError;
      case 'sessionExpired':
        return l10n.sessionExpired;
      case 'errorGeneric':
        return l10n.errorGeneric;
      case 'errorSaveMemory':
        return l10n.errorSaveMemory;
      case 'errorMemoryNotFound':
        return l10n.errorMemoryNotFound;
      case 'errorDownloadAudio':
        return l10n.errorDownloadAudio;
      case 'errorDownloadPhoto':
        return l10n.errorDownloadPhoto;
      case 'errorDeleteMemory':
        return l10n.errorDeleteMemory;
      case 'errorNoFeedback':
        return l10n.errorNoFeedback;
      case 'errorProcessing':
        return l10n.errorProcessing;
      case 'errorLoadAnalytics':
        return l10n.errorLoadAnalytics;
      case 'errorCheckInsight':
        return l10n.errorCheckInsight;
      case 'errorGenerateInsight':
        return l10n.errorGenerateInsight;
      case 'errorNoNotesThisWeek':
        return l10n.errorNoNotesThisWeek;
      case 'errorFetchEntries':
        return l10n.errorFetchEntries;
      case 'errorFetchDailyReport':
        return l10n.errorFetchDailyReport;
      default:
        return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: context.colors.shadowSoft,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward
                            : Icons.arrow_back,
                        size: 18,
                        color: context.colors.ink900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(widget.pageTitle,
                      style: context.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: context.colors.insightGradient,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: Alignment.center,
                            child: const Text('✨', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.periodLabel,
                                    style: context.memoryMeta.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(widget.cardSubtitle, style: context.sectionTitle.copyWith(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBody(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: context.colors.shadowSoft,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.purple700),
                ),
                const SizedBox(width: 10),
                Text(l10n.aiWriting,
                    style: context.memoryTitle.copyWith(fontSize: 13.5, color: AppColors.purple700)),
              ],
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: context.colors.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_error!, style: context.memoryTranscript.copyWith(color: AppColors.danger)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.purple100,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(l10n.tryAgain,
                    style: context.aiChip.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.colors.shadowSoft,
      ),
      child: Text(
        _text ?? '',
        style: context.memoryTranscript.copyWith(height: 1.9, fontSize: 14),
      ),
    );
  }
}
