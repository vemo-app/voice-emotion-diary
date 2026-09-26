import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color background;
  final Color surface;
  final Color ink900;
  final Color ink600;
  final Color ink400;
  final Color line;
  final Color happyBg;
  final Color happyFg;
  final Color happyBar;
  final Color sadBg;
  final Color sadFg;
  final Color sadBar;
  final Color angerBg;
  final Color angerFg;
  final Color angerBar;
  final Color neutralBg;
  final Color neutralFg;
  final Color neutralBar;
  final Color success;
  final Color danger;
  final Color dangerBg;
  final List<Color> insightGradient;
  final List<BoxShadow> shadowSoft;
  final List<BoxShadow> shadowButton;
  final List<BoxShadow> shadowFab;

  const SemanticColors({
    required this.background,
    required this.surface,
    required this.ink900,
    required this.ink600,
    required this.ink400,
    required this.line,
    required this.happyBg,
    required this.happyFg,
    required this.happyBar,
    required this.sadBg,
    required this.sadFg,
    required this.sadBar,
    required this.angerBg,
    required this.angerFg,
    required this.angerBar,
    required this.neutralBg,
    required this.neutralFg,
    required this.neutralBar,
    required this.success,
    required this.danger,
    required this.dangerBg,
    required this.insightGradient,
    required this.shadowSoft,
    required this.shadowButton,
    required this.shadowFab,
  });

  @override
  SemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? ink900,
    Color? ink600,
    Color? ink400,
    Color? line,
    Color? happyBg,
    Color? happyFg,
    Color? happyBar,
    Color? sadBg,
    Color? sadFg,
    Color? sadBar,
    Color? angerBg,
    Color? angerFg,
    Color? angerBar,
    Color? neutralBg,
    Color? neutralFg,
    Color? neutralBar,
    Color? success,
    Color? danger,
    Color? dangerBg,
    List<Color>? insightGradient,
    List<BoxShadow>? shadowSoft,
    List<BoxShadow>? shadowButton,
    List<BoxShadow>? shadowFab,
  }) {
    return SemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink900: ink900 ?? this.ink900,
      ink600: ink600 ?? this.ink600,
      ink400: ink400 ?? this.ink400,
      line: line ?? this.line,
      happyBg: happyBg ?? this.happyBg,
      happyFg: happyFg ?? this.happyFg,
      happyBar: happyBar ?? this.happyBar,
      sadBg: sadBg ?? this.sadBg,
      sadFg: sadFg ?? this.sadFg,
      sadBar: sadBar ?? this.sadBar,
      angerBg: angerBg ?? this.angerBg,
      angerFg: angerFg ?? this.angerFg,
      angerBar: angerBar ?? this.angerBar,
      neutralBg: neutralBg ?? this.neutralBg,
      neutralFg: neutralFg ?? this.neutralFg,
      neutralBar: neutralBar ?? this.neutralBar,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      dangerBg: dangerBg ?? this.dangerBg,
      insightGradient: insightGradient ?? this.insightGradient,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowButton: shadowButton ?? this.shadowButton,
      shadowFab: shadowFab ?? this.shadowFab,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink900: Color.lerp(ink900, other.ink900, t)!,
      ink600: Color.lerp(ink600, other.ink600, t)!,
      ink400: Color.lerp(ink400, other.ink400, t)!,
      line: Color.lerp(line, other.line, t)!,
      happyBg: Color.lerp(happyBg, other.happyBg, t)!,
      happyFg: Color.lerp(happyFg, other.happyFg, t)!,
      happyBar: Color.lerp(happyBar, other.happyBar, t)!,
      sadBg: Color.lerp(sadBg, other.sadBg, t)!,
      sadFg: Color.lerp(sadFg, other.sadFg, t)!,
      sadBar: Color.lerp(sadBar, other.sadBar, t)!,
      angerBg: Color.lerp(angerBg, other.angerBg, t)!,
      angerFg: Color.lerp(angerFg, other.angerFg, t)!,
      angerBar: Color.lerp(angerBar, other.angerBar, t)!,
      neutralBg: Color.lerp(neutralBg, other.neutralBg, t)!,
      neutralFg: Color.lerp(neutralFg, other.neutralFg, t)!,
      neutralBar: Color.lerp(neutralBar, other.neutralBar, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      insightGradient: [
        Color.lerp(insightGradient[0], other.insightGradient[0], t)!,
        Color.lerp(insightGradient[1], other.insightGradient[1], t)!,
      ],
      shadowSoft: BoxShadow.lerpList(shadowSoft, other.shadowSoft, t)!,
      shadowButton: BoxShadow.lerpList(shadowButton, other.shadowButton, t)!,
      shadowFab: BoxShadow.lerpList(shadowFab, other.shadowFab, t)!,
    );
  }

  static const light = SemanticColors(
    background: Color(0xFFF7F8FC),
    surface: Color(0xFFFFFFFF),
    ink900: Color(0xFF1B1D29),
    ink600: Color(0xFF5B5E70),
    ink400: Color(0xFF9295A6),
    line: Color(0xFFEEF0F6),
    happyBg: Color(0xFFFFF3D6),
    happyFg: Color(0xFFB8860B),
    happyBar: Color(0xFFFFC94D),
    sadBg: Color(0xFFE4EDFF),
    sadFg: Color(0xFF3357C9),
    sadBar: Color(0xFF6E93FF),
    angerBg: Color(0xFFFFE4E0),
    angerFg: Color(0xFFC4402E),
    angerBar: Color(0xFFFF7A66),
    neutralBg: Color(0xFFECEDF3),
    neutralFg: Color(0xFF6B6E80),
    neutralBar: Color(0xFFB7BACB),
    success: Color(0xFF2FAE6B),
    danger: Color(0xFFE5484D),
    dangerBg: Color(0xFFFDECEC),
    insightGradient: [Color(0xFFE8ECFE), Color(0xFFF0EBFF)], // blue100 -> purple100
    shadowSoft: [
      BoxShadow(color: Color.fromRGBO(30, 42, 110, 0.06), blurRadius: 8, offset: Offset(0, 2)),
      BoxShadow(color: Color.fromRGBO(30, 42, 110, 0.06), blurRadius: 24, offset: Offset(0, 8)),
    ],
    shadowButton: [
      BoxShadow(color: Color.fromRGBO(124, 77, 255, 0.32), blurRadius: 26, offset: Offset(0, 12)),
      BoxShadow(color: Color.fromRGBO(61, 90, 254, 0.22), blurRadius: 12, offset: Offset(0, 5)),
    ],
    shadowFab: [
      BoxShadow(color: Color.fromRGBO(124, 77, 255, 0.35), blurRadius: 20, offset: Offset(0, 8)),
      BoxShadow(color: Color.fromRGBO(61, 90, 254, 0.25), blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  static const dark = SemanticColors(
    background: Color(0xFF0F1017),
    surface: Color(0xFF1B1D29),
    ink900: Color(0xFFFFFFFF),
    ink600: Color(0xFFB7BACB),
    ink400: Color(0xFF9295A6),
    line: Color(0xFF252833),
    happyBg: Color(0xFF332B14),
    happyFg: Color(0xFFFFD98C),
    happyBar: Color(0xFFFFC94D),
    sadBg: Color(0xFF1A2233),
    sadFg: Color(0xFF8CB4FF),
    sadBar: Color(0xFF6E93FF),
    angerBg: Color(0xFF331A1A),
    angerFg: Color(0xFFFF8C8C),
    angerBar: Color(0xFFFF7A66),
    neutralBg: Color(0xFF252833),
    neutralFg: Color(0xFFB7BACB),
    neutralBar: Color(0xFFB7BACB),
    success: Color(0xFF2FAE6B),
    danger: Color(0xFFE5484D),
    dangerBg: Color(0xFF331A1A),
    insightGradient: [Color(0xFF232A4D), Color(0xFF34215C)], // dark blue/purple - keeps white/light-gray text readable on top
    shadowSoft: [
      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
    ],
    shadowButton: [
      BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.4), blurRadius: 26, offset: Offset(0, 12)),
    ],
    shadowFab: [
      BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.4), blurRadius: 20, offset: Offset(0, 8)),
    ],
  );
}

extension BuildContextThemeX on BuildContext {
  SemanticColors get colors => Theme.of(this).extension<SemanticColors>()!;
}

extension AppTextStylesX on BuildContext {
  String? get _fontFamily =>
      Localizations.localeOf(this).languageCode == 'fa'
          ? GoogleFonts.vazirmatn().fontFamily
          : GoogleFonts.inter().fontFamily;

  TextStyle get heroTitle => TextStyle(fontFamily: _fontFamily, fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3);
  TextStyle get heroSubtitle => TextStyle(fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85), height: 1.8);
  TextStyle get fieldLabel => TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: colors.ink600);
  TextStyle get fieldInput => TextStyle(fontFamily: _fontFamily, fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink900);
  TextStyle get fieldPlaceholder => TextStyle(fontFamily: _fontFamily, fontSize: 13.5, fontWeight: FontWeight.w500, color: colors.ink400);
  TextStyle get pwHint => TextStyle(fontFamily: _fontFamily, fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.ink400);
  TextStyle get termsText => TextStyle(fontFamily: _fontFamily, fontSize: 11.5, fontWeight: FontWeight.w500, color: colors.ink600, height: 1.8);
  TextStyle get termsLink => TextStyle(fontFamily: _fontFamily, fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF7C4DFF));
  TextStyle get buttonText => TextStyle(fontFamily: _fontFamily, fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white);
  TextStyle get loginRowText => TextStyle(fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.ink600);
  TextStyle get loginRowLink => TextStyle(fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF7C4DFF));
  TextStyle get greetDate => TextStyle(fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w500, color: colors.ink400);
  TextStyle get chartTitle => TextStyle(fontFamily: _fontFamily, fontSize: 14.5, fontWeight: FontWeight.w700, color: colors.ink900);
  TextStyle get chartSub => TextStyle(fontFamily: _fontFamily, fontSize: 11.5, fontWeight: FontWeight.w500, color: colors.ink400);
  TextStyle get chartBadge => TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF7C4DFF));
  TextStyle get emoPct => TextStyle(fontFamily: _fontFamily, fontSize: 10.5, fontWeight: FontWeight.w700);
  TextStyle get emoLabel => TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink600);
  TextStyle get sectionTitle => TextStyle(fontFamily: _fontFamily, fontSize: 15.5, fontWeight: FontWeight.w700, color: colors.ink900);
  TextStyle get sectionCount => TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink400);
  TextStyle get memoryTitle => TextStyle(fontFamily: _fontFamily, fontSize: 14.5, fontWeight: FontWeight.w700, color: colors.ink900);
  TextStyle get memoryMeta => TextStyle(fontFamily: _fontFamily, fontSize: 11.5, fontWeight: FontWeight.w500, color: colors.ink400);
  TextStyle get memoryTranscript => TextStyle(fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w400, color: colors.ink600, height: 1.8);
  TextStyle get aiChip => TextStyle(fontFamily: _fontFamily, fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF7C4DFF));
  TextStyle get fabText => TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white);
  TextStyle get navLabel => TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600);
}
