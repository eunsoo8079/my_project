// 음악 취향 설문조사 데이터 모델
// 2축 (에너지/감성) 가중치 기반 스펙트럼 시스템

class SurveyQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String axis; // 'energy', 'mood'

  const SurveyQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.axis,
  });
}

class MusicType {
  final int id;
  final String name;
  final String emoji;
  final String description;
  final String folderName;

  const MusicType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.folderName,
  });
}

class SurveyData {
  static const List<SurveyQuestion> questions = [
    // ⚡ 에너지 축 — Q1~Q5 (5문항)
    // 일상 2개 → 음악 3개로 자연스럽게 전환
    SurveyQuestion(
      id: 1,
      question: '쉬는 날 아침, 눈을 떴을 때\n가장 먼저 하고 싶은 건?',
      optionA: '이불 속에서 천천히 멍 때리기',
      optionB: '바로 일어나서 오늘 할 일 시작',
      axis: 'energy',
    ),
    SurveyQuestion(
      id: 2,
      question: '친구가 저녁 뭐 먹을지\n고르라고 하면?',
      optionA: '아무거나 괜찮아, 네가 골라',
      optionB: '여기 가보자! 맛집 리스트 꺼내기',
      axis: 'energy',
    ),
    SurveyQuestion(
      id: 3,
      question: '드라이브할 때\n틀고 싶은 음악은?',
      optionA: '창밖 풍경과 어울리는 잔잔한 음악',
      optionB: '볼륨 높여서 신나게 달리는 음악',
      axis: 'energy',
    ),
    SurveyQuestion(
      id: 4,
      question: '이어폰 끼고 길 걸을 때\n어떤 느낌이 좋아?',
      optionA: '세상이 느리게 보이는 잔잔한 느낌',
      optionB: '발걸음이 빨라지는 신나는 느낌',
      axis: 'energy',
    ),
    SurveyQuestion(
      id: 5,
      question: '운동할 때 음악을 듣는다면?',
      optionA: '페이스 유지하는 편안한 음악',
      optionB: '한계까지 밀어붙이는 강렬한 비트',
      axis: 'energy',
    ),

    // 💖 감성 축 — Q6~Q9 (4문항)
    // 일상 2개 → 음악 2개
    SurveyQuestion(
      id: 6,
      question: '비 오는 날, 창문 밖을\n보면서 어떤 생각이 들어?',
      optionA: '왠지 센치해지면서 옛 생각이 나',
      optionB: '비 오니까 집에 있기 딱 좋다',
      axis: 'mood',
    ),
    SurveyQuestion(
      id: 7,
      question: '영화를 볼 때\n더 끌리는 장면은?',
      optionA: '감정이 북받쳐 눈물이 나는 장면',
      optionB: '멋진 영상미와 연출에 감탄하는 장면',
      axis: 'mood',
    ),
    SurveyQuestion(
      id: 8,
      question: '노래 들을 때\n더 끌리는 건?',
      optionA: '가사에 빠져들며 감정이입',
      optionB: '멜로디나 비트 자체의 느낌',
      axis: 'mood',
    ),
    SurveyQuestion(
      id: 9,
      question: '콘서트에 간다면\n어떤 순간이 좋아?',
      optionA: '잔잔한 곡에 관객이 다 같이 떼창할 때',
      optionB: '클라이맥스에서 모두가 뛸 때',
      axis: 'mood',
    ),
  ];

  /// 4가지 음악 기질 (결과 표시용)
  /// ID = (에너지 >= 0.5 ? 1 : 0) * 2 + (감성 >= 0.5 ? 1 : 0)
  static const List<MusicType> types = [
    MusicType(
      id: 0, // 차분 + 서정
      name: '고요한 감성파',
      emoji: '🌙',
      description: '음악으로 조용히 감정에 빠지는 당신\n잔잔한 선율이 마음을 어루만져요',
      folderName: 'calm',
    ),
    MusicType(
      id: 1, // 차분 + 쿨
      name: '차분한 무드파',
      emoji: '📚',
      description: '담백하게 분위기를 즐기는 당신\n음악이 일상의 배경이 되어줘요',
      folderName: 'calm',
    ),
    MusicType(
      id: 2, // 활발 + 서정
      name: '감성 에너지파',
      emoji: '🎤',
      description: '음악에 감정을 실어 표현하는 당신\n신나면서도 감성적인 순간을 좋아해요',
      folderName: 'energetic',
    ),
    MusicType(
      id: 3, // 활발 + 쿨
      name: '강렬한 비트파',
      emoji: '🔥',
      description: '음악으로 에너지를 발산하는 당신\n강렬한 비트가 일상에 활력을 줘요',
      folderName: 'energetic',
    ),
  ];

  /// 답변 목록 → 연속 점수 계산
  /// answers: 0-indexed, 값은 0(A) 또는 1(B)
  /// 반환: {energyScore: 0.0~1.0, moodScore: 0.0~1.0, typeId: 0~3}
  static Map<String, dynamic> calculateScores(List<int> answers) {
    assert(answers.length == 9);

    int energyB = 0; // 에너지 축 B 선택 수 (5문항)
    int moodB = 0;   // 감성 축 B 선택 수 (4문항)

    for (int i = 0; i < answers.length; i++) {
      final axis = questions[i].axis;
      if (answers[i] == 1) {
        if (axis == 'energy') energyB++;
        if (axis == 'mood') moodB++;
      }
    }

    final energyScore = energyB / 5.0; // 0.0 ~ 1.0
    final moodScore = moodB / 4.0;     // 0.0 ~ 1.0

    // 기질 ID: (에너지 높으면 2) + (감성 쿨이면 1)
    final energyHigh = energyScore >= 0.5 ? 1 : 0;
    final moodCool = moodScore >= 0.5 ? 1 : 0;
    final typeId = (energyHigh * 2) + moodCool;

    return {
      'energyScore': energyScore,
      'moodScore': moodScore,
      'typeId': typeId,
    };
  }

  /// 에너지 점수로 음악 폴더 결정
  static String getMusicFolder(double energyScore) {
    return energyScore >= 0.5 ? 'energetic' : 'calm';
  }

  static MusicType getTypeById(int id) {
    return types.firstWhere((t) => t.id == id, orElse: () => types[0]);
  }
}
