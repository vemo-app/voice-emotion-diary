import 'package:flutter/material.dart';
import '../../../models/emotion.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';

/// A single chart item: an emotion + its percentage + bar height (0 to 1).
/// percent and barFraction are kept separate rather than deriving the bar
/// height directly from the percentage, since the bar isn't strictly
/// proportional to the percentage (even the smallest value keeps a
/// minimum height so it stays visible).
class EmotionChartItem {
  final EmotionType emotion;
  final String percentLabel;
  final double barFraction; // between 0 and 1, relative bar height

  const EmotionChartItem({
    required this.emotion,
    required this.percentLabel,
    required this.barFraction,
  });
}

class EmotionChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final List<EmotionChartItem> items;

  const EmotionChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.colors.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.chartTitle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: context.chartSub),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(badgeText, style: context.chartBadge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items.map((item) => _buildColumn(context, item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, EmotionChartItem item) {
    return Expanded(
      child: Column(
        children: [
          Text(
            item.percentLabel,
            style: context.emoPct.copyWith(color: item.emotion.fg(context)),
          ),
          const SizedBox(height: 8),
          // A gray track filled from the bottom with a colored bar - like
          // a vertical bar chart column. Align(bottomCenter) is used so
          // the bar fills upward from the bottom instead of the top.
          Container(
            width: 32,
            height: 74,
            decoration: BoxDecoration(
              color: context.colors.line,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: item.barFraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.emotion.bar(context),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(item.emotion.emoji, style: const TextStyle(fontSize: 20, height: 1)),
          const SizedBox(height: 4),
          Text(item.emotion.label(context), style: context.emoLabel),
        ],
      ),
    );
  }
}
