class EmotionRecord {
  final int? id;
  final DateTime date;
  final String time; // "HH:MM" 형식
  final String emotionType; // 이모지
  final int emotionIntensity; // 1-100
  final String? content;
  final String? musicUrl;
  final String? tags; // 쉼표 구분 태그 (예: "직장,운동")
  final DateTime createdAt;

  EmotionRecord({
    this.id,
    required this.date,
    required this.time,
    required this.emotionType,
    required this.emotionIntensity,
    this.content,
    this.musicUrl,
    this.tags,
    required this.createdAt,
  });

  // 태그 목록으로 변환
  List<String> get tagList =>
      tags?.split(',').where((t) => t.isNotEmpty).toList() ?? [];

  // DB에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'time': time,
      'emotion_type': emotionType,
      'emotion_intensity': emotionIntensity,
      'content': content,
      'music_url': musicUrl,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Map에서 객체 생성
  factory EmotionRecord.fromMap(Map<String, dynamic> map) {
    return EmotionRecord(
      id: map['id'] as int?,
      date: DateTime.parse(map['date']),
      time: map['time'] as String,
      emotionType: map['emotion_type'] as String,
      emotionIntensity: map['emotion_intensity'] as int,
      content: map['content'] as String?,
      musicUrl: map['music_url'] as String?,
      tags: map['tags'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
