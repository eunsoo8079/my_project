// 감정 × 에너지별 큐레이션 트랙 (CSV에서 로드)
// 곡 추가/변경: assets/curated_tracks.csv 파일을 편집하세요
// CSV 형식: style,emotion,trackId,artist,title

import 'package:flutter/services.dart';

class CuratedTracks {
  static bool _loaded = false;
  static final Map<String, List<int>> _calm = {};
  static final Map<String, List<int>> _energetic = {};

  /// 감정 이모지 → 키 매핑
  static const Map<String, String> emotionKeys = {
    '😊': 'happy',
    '😢': 'sad',
    '😡': 'angry',
    '😌': 'relax',
    '😰': 'anxious',
    '😑': 'neutral',
    '🤔': 'curious',
  };

  /// CSV 파일에서 트랙 목록 로드
  static Future<void> load() async {
    if (_loaded) return;
    try {
      final csv = await rootBundle.loadString('assets/curated_tracks.csv');
      final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();

      // 헤더 스킵 (첫 번째 줄)
      for (var i = 1; i < lines.length; i++) {
        final cols = lines[i].trim().split(',');
        if (cols.length < 3) continue;

        final style = cols[0].trim();   // calm / energetic
        final emotion = cols[1].trim(); // happy, sad, ...
        final trackId = int.tryParse(cols[2].trim());
        if (trackId == null) continue;

        final map = style == 'energetic' ? _energetic : _calm;
        map.putIfAbsent(emotion, () => []);
        map[emotion]!.add(trackId);
      }
      _loaded = true;
    } catch (e) {
      // CSV 로드 실패 시 기본값 사용
      _calm['happy'] = [1560113347];
      _energetic['happy'] = [1597024424];
      _loaded = true;
    }
  }

  /// 에너지 점수 + 감정으로 trackId 목록 가져오기
  static List<int> getTracks(double energyScore, String emotion) {
    final emotionKey = emotionKeys[emotion] ?? 'happy';
    final tracks = energyScore >= 0.5
        ? _energetic[emotionKey]
        : _calm[emotionKey];
    return tracks ?? _calm['happy'] ?? [1560113347];
  }
}
