import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_colors_extension.dart';
import '../analystics/analystics.dart';
import '../history/history_calendar_page.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _service = UserService();

  bool _loading = true;
  String? _error;
  UserProfile? _profile;
  ProfileSummary? _summary;

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
      final results = await Future.wait([_service.getMe(), _service.getSummary()]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as UserProfile;
        _summary = results[1] as ProfileSummary;
        _loading = false;
      });
    } on UserException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        if (e.message == 'connectionError') {
          _error = l10n.connectionError;
        } else if (e.message == 'sessionExpired') {
          _error = l10n.sessionExpired;
        } else {
          _error = l10n.errorLoading;
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'error'; // Localized in build
        _loading = false;
      });
    }
  }

  void _handleNavTap(int index) {
    if (index == 3) return; // Already on the profile page.
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
      return;
    }
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
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())).then((_) {
      // Refresh data to reflect any potential changes (e.g., username, email).
      _loadData();
    });
  }

  void _handleAvatarEditTap() {
    final l10n = AppLocalizations.of(context)!;
    // Profile picture upload is currently not supported by the backend.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon(l10n.editProfile))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: context.colors.background,
        bottomNavigationBar: BottomNav(currentIndex: 3, onTap: _handleNavTap),
        body: SafeArea(
          bottom: false,
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
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 6),
                            _buildHeader(context, l10n),
                            _buildProfileHero(context, l10n),
                            const SizedBox(height: 4),
                            _buildStatBox(context, l10n),
                            const SizedBox(height: 16),
                            _buildDistributionCard(context, l10n),
                          ],
                        ),
                      ),
                    ),
        ),
      );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.profileTitle, style: context.sectionTitle.copyWith(fontSize: 19, fontWeight: FontWeight.w800)),
          GestureDetector(
            onTap: _openSettings,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(100), boxShadow: context.colors.shadowButton),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 7),
                  Text(l10n.settingsTitle, style: context.pwHint.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple500, AppColors.blue700]),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: context.colors.shadowSoft,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
              ),
              Positioned(
                bottom: -2,
                left: -2,
                child: GestureDetector(
                  onTap: _handleAvatarEditTap,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: context.colors.surface, shape: BoxShape.circle, boxShadow: context.colors.shadowSoft),
                    alignment: Alignment.center,
                    child: const Icon(Icons.edit, size: 13, color: AppColors.purple700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_profile!.username, style: context.sectionTitle.copyWith(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
              l10n.joinedDate(Localizations.localeOf(context).languageCode == 'fa'
                  ? _profile!.joinedMonthLabel
                  : '${LocalizedDate.getMonthName(_profile!.createdAt.month, context, isJalali: false)} ${_profile!.createdAt.year}'),
              style: context.pwHint.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(16), boxShadow: context.colors.shadowSoft),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text('🎙️', style: TextStyle(fontSize: 17)),
            const SizedBox(height: 6),
            Text(_persianDigits(_summary!.totalNotes, context), style: context.sectionTitle.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(l10n.totalMemories, style: context.pwHint.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionCard(BuildContext context, AppLocalizations l10n) {
    final dist = _summary!.emotionDistribution;
    final hasData = _summary!.scoredNotesCount > 0;
    final barColors = _getEmotionBarColors(context);

    final emotionLabels = {
      'happiness': l10n.happiness,
      'sadness': l10n.sadness,
      'anger': l10n.anger,
      'neutral': l10n.neutral,
    };
    final emotionEmojis = {
      'happiness': l10n.happinessEmoji,
      'sadness': l10n.sadnessEmoji,
      'anger': l10n.angerEmoji,
      'neutral': l10n.neutralEmoji,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(20), boxShadow: context.colors.shadowSoft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.emotionDistribution, style: context.memoryTitle.copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.noData, style: context.pwHint.copyWith(fontSize: 12)),
            )
          else
            ..._emotionOrder.map((key) {
              final value = dist[key] ?? 0;
              final pct = (value * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(emotionEmojis[key]!, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 72,
                      child: Text(
                        emotionLabels[key]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.pwHint.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: context.colors.ink600),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0),
                          minHeight: 9,
                          backgroundColor: context.colors.line,
                          valueColor: AlwaysStoppedAnimation(barColors[key]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 32,
                      child: Text(l10n.percent(_persianDigits(pct, context)), textAlign: TextAlign.left, style: context.pwHint.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, color: context.colors.ink900)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
