import 'package:flutter/material.dart';
import '../../../models/emotion.dart';
import '../../../models/memory_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localized_date.dart';

class MemoryCard extends StatelessWidget {
  final MemoryEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap; // tap on the card itself - opens the detail screen
  final VoidCallback? onFeedbackTap; // tap on the "AI feedback" chip

  const MemoryCard({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onFeedbackTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: context.colors.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dominant emotion emoji badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.dominantEmotion.bg(context),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(entry.dominantEmotion.emoji,
                      style: const TextStyle(fontSize: 19)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: context.memoryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(LocalizedDate.formatNumber(entry.timeLabel, context), style: context.memoryMeta),
                          _buildDot(context),
                          Text(
                              entry.durationLabel == 'processing'
                                  ? AppLocalizations.of(context)!.processing
                                  : entry.durationLabel,
                              style: context.memoryMeta),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildMiniBars(context),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.note,
              style: context.memoryTranscript,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.colors.line)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onFeedbackTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.purple100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              gradient: AppColors.heroGradient,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text('✦',
                                style: TextStyle(fontSize: 9, color: Colors.white)),
                          ),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.aiFeedback,
                              style: context.aiChip),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _iconButton(context, icon: Icons.edit_outlined, onTap: onEdit),
                      const SizedBox(width: 6),
                      _iconButton(
                        context,
                        icon: Icons.delete_outline,
                        onTap: onDelete,
                        color: const Color(0xFFC4402E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.ink400,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Four small bars showing this entry's emotion mix - a miniature
  /// version of the chart at the top of the home screen, purely
  /// decorative here (no labels or percentages).
  Widget _buildMiniBars(BuildContext context) {
    const maxHeight = 28.0;
    return SizedBox(
      height: maxHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: EmotionType.values.map((emotion) {
          final fraction = entry.emotionMix[emotion] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 5,
              height: maxHeight * fraction.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: emotion.bar(context),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _iconButton(BuildContext context, {required IconData icon, VoidCallback? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: color ?? context.colors.ink600),
      ),
    );
  }
}
