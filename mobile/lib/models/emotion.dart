import 'package:flutter/material.dart';
import '../widgets/theme/app_colors_extension.dart';
import '../l10n/app_localizations.dart';

enum EmotionType { happy, sad, anger, neutral }

extension EmotionTypeX on EmotionType {
  String get emoji {
    switch (this) {
      case EmotionType.happy:
        return '😊';
      case EmotionType.sad:
        return '😢';
      case EmotionType.anger:
        return '😠';
      case EmotionType.neutral:
        return '😐';
    }
  }

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case EmotionType.happy:
        return l10n.happiness;
      case EmotionType.sad:
        return l10n.sadness;
      case EmotionType.anger:
        return l10n.anger;
      case EmotionType.neutral:
        return l10n.neutral;
    }
  }

  Color bg(BuildContext context) {
    switch (this) {
      case EmotionType.happy:
        return context.colors.happyBg;
      case EmotionType.sad:
        return context.colors.sadBg;
      case EmotionType.anger:
        return context.colors.angerBg;
      case EmotionType.neutral:
        return context.colors.neutralBg;
    }
  }

  Color fg(BuildContext context) {
    switch (this) {
      case EmotionType.happy:
        return context.colors.happyFg;
      case EmotionType.sad:
        return context.colors.sadFg;
      case EmotionType.anger:
        return context.colors.angerFg;
      case EmotionType.neutral:
        return context.colors.neutralFg;
    }
  }

  Color bar(BuildContext context) {
    switch (this) {
      case EmotionType.happy:
        return context.colors.happyBar;
      case EmotionType.sad:
        return context.colors.sadBar;
      case EmotionType.anger:
        return context.colors.angerBar;
      case EmotionType.neutral:
        return context.colors.neutralBar;
    }
  }
}
