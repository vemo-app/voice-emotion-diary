class UserProfile {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final String joinedMonthLabel; // e.g. "Farvardin 1404" - provided by the backend
  final String theme; // "default" | "dark" | "night"
  final String language; // "default" | "fa" | "en"

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.joinedMonthLabel,
    required this.theme,
    required this.language,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      joinedMonthLabel: json['joined_month_label'] as String,
      theme: json['theme'] as String? ?? 'default',
      language: json['language'] as String? ?? 'default',
    );
  }
}

class ProfileSummary {
  final int totalNotes;
  final int scoredNotesCount;
  final Map<String, double> emotionDistribution; // anger/happiness/sadness/neutral

  ProfileSummary({
    required this.totalNotes,
    required this.scoredNotesCount,
    required this.emotionDistribution,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      totalNotes: json['total_notes'] as int,
      scoredNotesCount: json['scored_notes_count'] as int,
      emotionDistribution: {
        'anger': (json['anger'] as num).toDouble(),
        'happiness': (json['happiness'] as num).toDouble(),
        'sadness': (json['sadness'] as num).toDouble(),
        'neutral': (json['neutral'] as num).toDouble(),
      },
    );
  }
}
