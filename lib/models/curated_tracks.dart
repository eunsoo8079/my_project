// 감정 × 에너지별 큐레이션 트랙 (iTunes trackId)
// 나중에 곡을 바꾸고 싶으면 trackId만 교체하면 됩니다.
// trackId 검색: https://itunes.apple.com/search?term=검색어&country=KR&media=music&entity=song

class CuratedTracks {
  /// 감정 이모지 → 파일명 매핑
  static const Map<String, String> emotionKeys = {
    '😊': 'happy',
    '😢': 'sad',
    '😡': 'angry',
    '😌': 'relax',
    '😰': 'anxious',
    '😑': 'neutral',
    '🤔': 'curious',
  };

  /// calm 스타일 곡 (에너지 < 0.5)
  static const Map<String, List<int>> calm = {
    'happy': [
      1560113347, // 아이유 - 봄 안녕 봄
      1543850904, // 성시경 - 거리에서
    ],
    'sad': [
      1732912110, // 폴킴 - 비
      1448341239, // 이소라 - 바람이 분다
    ],
    'angry': [
      1448341239, // 이소라 - 바람이 분다
    ],
    'relax': [
      1543850904, // 성시경 - 거리에서
      1560113347, // 아이유 - 봄 안녕 봄
    ],
    'anxious': [
      1732912110, // 폴킴 - 비
    ],
    'neutral': [
      1543850904, // 성시경 - 거리에서
    ],
    'curious': [
      1560113347, // 아이유 - 봄 안녕 봄
    ],
  };

  /// energetic 스타일 곡 (에너지 >= 0.5)
  static const Map<String, List<int>> energetic = {
    'happy': [
      1597024424, // BTS - Dynamite
      1456103133, // 잔나비 - 주저하는 연인들을 위해
    ],
    'sad': [
      1523257572, // 박효신 - 야생화
      1471938396, // DAY6 - 한 페이지가 될 수 있게
    ],
    'angry': [
      1471938396, // DAY6 - 한 페이지가 될 수 있게
      1450778317, // 혁오 - TOMBOY
    ],
    'relax': [
      1456103133, // 잔나비 - 주저하는 연인들을 위해
    ],
    'anxious': [
      1523257572, // 박효신 - 야생화
    ],
    'neutral': [
      1450778317, // 혁오 - TOMBOY
    ],
    'curious': [
      1597024424, // BTS - Dynamite
    ],
  };

  /// 에너지 점수 + 감정으로 trackId 목록 가져오기
  static List<int> getTracks(double energyScore, String emotion) {
    final emotionKey = emotionKeys[emotion] ?? 'happy';
    final tracks = energyScore >= 0.5
        ? energetic[emotionKey]
        : calm[emotionKey];
    return tracks ?? calm['happy']!;
  }
}
