import '../models/emotion_record.dart';

class Insight {
  final String icon;
  final String text;

  const Insight({required this.icon, required this.text});
}

class InsightService {
  // ── 부정 감정 이모지 ──
  static const _negativeEmotions = {'😡', '😢', '😰'};
  // ── 긍정 감정 이모지 ──
  static const _positiveEmotions = {'😊', '😌'};

  /// 주간 인사이트 생성 (최대 3개)
  /// referenceDate 기준으로 해당 주의 인사이트를 생성
  static List<Insight> generateWeeklyInsights(
    List<EmotionRecord> allRecords, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final weekStart = ref.subtract(Duration(days: ref.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEndDate = weekStartDate.add(const Duration(days: 7));

    final weekRecords = allRecords
        .where((r) => !r.date.isBefore(weekStartDate) && r.date.isBefore(weekEndDate))
        .toList();

    final lastWeekStart = weekStartDate.subtract(const Duration(days: 7));
    final lastWeekRecords = allRecords
        .where((r) => !r.date.isBefore(lastWeekStart) && r.date.isBefore(weekStartDate))
        .toList();

    final insights = <Insight>[];

    // 기록 부족 체크 (최우선)
    if (weekRecords.length < 3) {
      insights.add(Insight(
        icon: '📝',
        text: '이 주의 기록이 ${weekRecords.length}개뿐이에요. 꾸준히 기록해봐요!',
      ));
      if (weekRecords.isEmpty) return insights;
    }

    // 1. 특정 태그 + 부정 감정 집중
    final tagNegInsight = _analyzeTagNegative(weekRecords);
    if (tagNegInsight != null) insights.add(tagNegInsight);

    // 2. 특정 태그 + 긍정 감정
    final tagPosInsight = _analyzeTagPositive(weekRecords);
    if (tagPosInsight != null) insights.add(tagPosInsight);

    // 3. 특정 요일 부정 감정 집중
    final dayInsight = _analyzeDayPattern(weekRecords);
    if (dayInsight != null) insights.add(dayInsight);

    // 4. 연속 긍정 기록
    final streakInsight = _analyzePositiveStreak(allRecords, ref);
    if (streakInsight != null) insights.add(streakInsight);

    // 5. 주간 평균 강도 변화
    final intensityInsight = _analyzeIntensityChange(weekRecords, lastWeekRecords);
    if (intensityInsight != null) insights.add(intensityInsight);

    // 6. 가장 많이 쓴 태그
    final topTagInsight = _analyzeTopTag(weekRecords);
    if (topTagInsight != null) insights.add(topTagInsight);

    // 최대 3개만 반환
    return insights.take(3).toList();
  }

  // ── 패턴 1: 특정 태그 + 부정 감정 ──
  static Insight? _analyzeTagNegative(List<EmotionRecord> records) {
    final tagNegCount = <String, int>{};
    for (var r in records) {
      if (_negativeEmotions.contains(r.emotionType)) {
        for (var tag in r.tagList) {
          tagNegCount[tag] = (tagNegCount[tag] ?? 0) + 1;
        }
      }
    }
    if (tagNegCount.isEmpty) return null;

    final topEntry = tagNegCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (topEntry.value < 2) return null;

    return Insight(icon: '⚠️', text: _getNegativeTagText(topEntry.key));
  }

  // ── 패턴 2: 특정 태그 + 긍정 감정 ──
  static Insight? _analyzeTagPositive(List<EmotionRecord> records) {
    final tagPosCount = <String, int>{};
    for (var r in records) {
      if (_positiveEmotions.contains(r.emotionType)) {
        for (var tag in r.tagList) {
          tagPosCount[tag] = (tagPosCount[tag] ?? 0) + 1;
        }
      }
    }
    if (tagPosCount.isEmpty) return null;

    final topEntry = tagPosCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (topEntry.value < 2) return null;

    return Insight(icon: '✨', text: _getPositiveTagText(topEntry.key));
  }

  // ── 패턴 3: 특정 요일 부정 감정 집중 ──
  static Insight? _analyzeDayPattern(List<EmotionRecord> records) {
    final dayNegCount = <int, int>{};
    for (var r in records) {
      if (_negativeEmotions.contains(r.emotionType)) {
        dayNegCount[r.date.weekday] = (dayNegCount[r.date.weekday] ?? 0) + 1;
      }
    }
    if (dayNegCount.isEmpty) return null;

    final topDay = dayNegCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (topDay.value < 2) return null;

    const dayNames = {1: '월요일', 2: '화요일', 3: '수요일', 4: '목요일', 5: '금요일', 6: '토요일', 7: '일요일'};
    return Insight(
      icon: '📅',
      text: '이번 주는 ${dayNames[topDay.key]}에 스트레스가 집중됐어요',
    );
  }

  // ── 패턴 4: 연속 긍정 기록 ──
  static Insight? _analyzePositiveStreak(List<EmotionRecord> records, DateTime now) {
    int streak = 0;
    for (var i = 0; i < 14; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final record = records.where((r) => r.date.toIso8601String().split('T')[0] == dayStr).toList();

      if (record.isEmpty) break;
      if (_positiveEmotions.contains(record.first.emotionType)) {
        streak++;
      } else {
        break;
      }
    }
    if (streak < 2) return null;

    return Insight(
      icon: '🎉',
      text: '$streak일 연속 긍정적 감정을 기록했어요!',
    );
  }

  // ── 패턴 5: 주간 평균 강도 변화 ──
  static Insight? _analyzeIntensityChange(
    List<EmotionRecord> thisWeek,
    List<EmotionRecord> lastWeek,
  ) {
    if (thisWeek.isEmpty || lastWeek.isEmpty) return null;

    final thisAvg = thisWeek.map((r) => r.emotionIntensity).reduce((a, b) => a + b) / thisWeek.length;
    final lastAvg = lastWeek.map((r) => r.emotionIntensity).reduce((a, b) => a + b) / lastWeek.length;

    final diff = ((thisAvg - lastAvg) / lastAvg * 100).round().abs();
    if (diff < 10) return null;

    if (thisAvg < lastAvg) {
      return Insight(
        icon: '😊',
        text: '지난 주보다 감정 강도가 $diff% 낮아졌어요',
      );
    } else {
      return Insight(
        icon: '💭',
        text: '이번 주 감정 강도가 $diff% 높아졌어요. 마음 챙기기가 필요해요',
      );
    }
  }

  // ── 패턴 6: 가장 많이 쓴 태그 ──
  static Insight? _analyzeTopTag(List<EmotionRecord> records) {
    final tagCount = <String, int>{};
    for (var r in records) {
      for (var tag in r.tagList) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    if (tagCount.isEmpty) return null;

    final topTag = tagCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return Insight(
      icon: '🏷️',
      text: '이번 주 가장 많이 기록한 상황은 ${topTag.key}이에요',
    );
  }

  // ── 태그별 부정 감정 텍스트 매핑 ──
  static String _getNegativeTagText(String tag) {
    const mapping = {
      '직장': '직장에서 스트레스를 많이 받고 있어요. 퇴근 후 환기가 필요할 수 있어요',
      '학교': '학교 생활에서 힘든 감정이 자주 느껴지고 있어요',
      '공부': '공부 관련 부담이 감정에 영향을 주고 있어요. 적절한 휴식도 중요해요',
      '시험': '시험 스트레스가 쌓이고 있어요. 한 걸음씩 천천히 해봐요 💪',
      '가족': '가족 관계에서 어려움을 느끼고 있네요. 대화가 도움이 될 수 있어요',
      '친구': '친구 관계에서 부정적 감정이 반복되고 있어요',
      '연인': '연인과의 관계에서 감정 소모가 있는 것 같아요',
      '혼자': '혼자 있을 때 부정적 감정이 자주 찾아오고 있어요',
      '운동': '운동 중 스트레스를 느끼고 있어요. 강도를 조절해봐요',
      '건강': '건강 문제가 감정에 영향을 주고 있어요. 몸 관리에 신경 써주세요',
      '날씨': '날씨에 기분이 영향을 많이 받고 있어요',
    };
    return mapping[tag] ?? '$tag 관련 기록에서 부정적 감정이 많았어요';
  }

  // ── 태그별 긍정 감정 텍스트 매핑 ──
  static String _getPositiveTagText(String tag) {
    const mapping = {
      '운동': '운동할 때 긍정적인 감정을 자주 느끼고 있어요! 꾸준히 해봐요 🏃',
      '친구': '친구와 함께할 때 기분이 좋아지는 편이에요 😊',
      '연인': '연인과의 시간이 긍정적인 에너지를 주고 있어요 💛',
      '가족': '가족과 함께할 때 편안함을 느끼고 있어요',
      '취미': '취미 활동이 좋은 감정의 원천이 되고 있어요! 계속 즐겨봐요 ✨',
      '여행': '여행이 긍정적인 감정을 많이 가져다주고 있어요 🌿',
    };
    return mapping[tag] ?? '$tag 관련해서 긍정적인 감정이 많았어요!';
  }
}
