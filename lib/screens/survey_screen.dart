import 'package:flutter/material.dart';
import '../models/survey_data.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'survey_result_screen.dart';

class SurveyScreen extends StatefulWidget {
  final bool isRetake;

  const SurveyScreen({super.key, this.isRetake = false});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen>
    with SingleTickerProviderStateMixin {
  bool _showIntro = true; // 인트로 화면 표시 여부
  int _currentIndex = 0;
  final List<int> _answers = List.filled(9, -1); // -1 = 미답변
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startSurvey() {
    _animController.reset();
    setState(() {
      _showIntro = false;
    });
    _animController.forward();
  }

  void _selectAnswer(int answer) async {
    setState(() {
      _answers[_currentIndex] = answer;
    });

    // 잠깐 대기 후 다음 질문
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentIndex < 8) {
      _animController.reset();
      setState(() {
        _currentIndex++;
      });
      _animController.forward();
    } else {
      // 설문 완료 → 결과 계산 및 저장
      await _completeSurvey();
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      _animController.reset();
      setState(() {
        _currentIndex--;
      });
      _animController.forward();
    } else if (!_showIntro) {
      // 첫 번째 질문에서 뒤로가면 인트로로
      _animController.reset();
      setState(() {
        _showIntro = true;
      });
      _animController.forward();
    }
  }

  Future<void> _completeSurvey() async {
    final results = SurveyData.calculateScores(_answers);
    final typeId = results['typeId'] as int;
    final energyScore = results['energyScore'] as double;
    final moodScore = results['moodScore'] as double;
    final db = DatabaseService.instance;

    await db.setSetting('survey_completed', 'true');
    await db.setSetting('music_type', typeId.toString());
    await db.setSetting('energy_score', energyScore.toString());
    await db.setSetting('mood_score', moodScore.toString());
    await db.setSetting('survey_answers', _answers.join(','));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SurveyResultScreen(
            typeId: typeId,
            energyScore: energyScore,
            moodScore: moodScore,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isRetake && _showIntro,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_showIntro) {
          _goBack();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _showIntro ? _buildIntroPage() : _buildQuestionPage(),
            ),
          ),
        ),
      ),
    );
  }

  /// 인트로 안내 페이지
  Widget _buildIntroPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 뒤로가기 (재설문 시에만)
          if (widget.isRetake)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 36),

          const Spacer(flex: 2),

          // 이모지
          const Text('🎵', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),

          // 타이틀
          const Text(
            '음악 성향 테스트',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // 설명
          Text(
            '간단한 9개 질문으로\n당신의 음악 취향을 분석해요.\n\n결과에 따라 감정별 음악 추천이\n당신의 스타일에 맞게 바뀝니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 12),

          // 소요 시간
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⏱ 약 1분 소요',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          const Spacer(flex: 3),

          // 시작 버튼
          GestureDetector(
            onTap: _startSurvey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                '시작하기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 질문 페이지
  Widget _buildQuestionPage() {
    final question = SurveyData.questions[_currentIndex];
    final progress = (_currentIndex + 1) / 9;

    return Column(
      children: [
        const SizedBox(height: 20),

        // 상단 바: 뒤로가기 + 진행률
        Row(
          children: [
            // 뒤로가기 (항상 표시)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            const Spacer(),
            // 진행 카운터
            Text(
              '${_currentIndex + 1} / 9',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 프로그레스 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.primary.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        // 질문 영역
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.5,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 선택지 버튼들
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildOptionButton(
                label: question.optionA,
                isSelected: _answers[_currentIndex] == 0,
                onTap: () => _selectAnswer(0),
              ),
              const SizedBox(height: 14),
              _buildOptionButton(
                label: question.optionB,
                isSelected: _answers[_currentIndex] == 1,
                onTap: () => _selectAnswer(1),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
