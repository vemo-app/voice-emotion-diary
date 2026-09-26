import 'emotion.dart';

class MemoryEntry {
  final String id;
  final String title;
  final String timeLabel;
  final String durationLabel;
  final EmotionType dominantEmotion;
  final String note;
  final Map<EmotionType, double> emotionMix;
  final String status;
  final String? feedback; // AI feedback specific to this entry; may not be ready yet
  final bool hasImage;
  final double? durationSeconds;

  const MemoryEntry({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.durationLabel,
    required this.dominantEmotion,
    required this.note,
    required this.emotionMix,
    required this.status,
    this.feedback,
    this.hasImage = false,
    this.durationSeconds,
  });

  factory MemoryEntry.fromApi(Map<String, dynamic> json) {
    final emotionJson = json['emotion'] as Map<String, dynamic>?;

    var emotionMix = <EmotionType, double>{
      EmotionType.happy: 0,
      EmotionType.sad: 0,
      EmotionType.anger: 0,
      EmotionType.neutral: 0,
    };
    EmotionType dominant = EmotionType.neutral;

    if (emotionJson != null) {
      emotionMix = {
        EmotionType.happy: (emotionJson['happiness'] as num).toDouble(),
        EmotionType.sad: (emotionJson['sadness'] as num).toDouble(),
        EmotionType.anger: (emotionJson['anger'] as num).toDouble(),
        EmotionType.neutral: (emotionJson['neutral'] as num).toDouble(),
      };
      dominant =
          emotionMix.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    final status = json['status'] as String;
    final recordedAt = DateTime.parse(json['recorded_at'] as String).toLocal();

    return MemoryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      timeLabel: 
        '${recordedAt.hour.toString().padLeft(2, '0')}:${recordedAt.minute.toString().padLeft(2, '0')}',
      durationLabel: status == 'processing' ? 'processing' : '',
      dominantEmotion: dominant,
      // User's own note; stays empty if they didn't write anything.
      note: (json['note'] as String?) ?? '',
      emotionMix: emotionMix,
      status: status,
      feedback: json['feedback'] as String?,
      hasImage: (json['has_image'] as bool?) ?? false,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
    );
  }
}