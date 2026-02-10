import 'package:flutter/material.dart';
import '../models/survey_data.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SurveyResultScreen extends StatefulWidget {
  final int typeId;
  final double energyScore;
  final double moodScore;

  const SurveyResultScreen({
    super.key,
    required this.typeId,
    required this.energyScore,
    required this.moodScore,
  });

  @override
  State<SurveyResultScreen> createState() => _SurveyResultScreenState();
}

class _SurveyResultScreenState extends State<SurveyResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _barAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEnergyLabel(double score) {
    if (score <= 0.2) return '매우 차분';
    if (score <= 0.4) return '차분한 편';
    if (score <= 0.6) return '균형잡힌';
    if (score <= 0.8) return '활발한 편';
    return '매우 활발';
  }

  String _getMoodLabel(double score) {
    if (score <= 0.25) return '매우 서정적';
    if (score <= 0.5) return '서정적인 편';
    if (score <= 0.75) return '쿨한 편';
    return '매우 쿨';
  }

  @override
  Widget build(BuildContext context) {
    final musicType = SurveyData.getTypeById(widget.typeId);

    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 결과 카드
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(25),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '당신의 음악 성향',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 이모지
                          Text(
                            musicType.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 12),
                          // 기질 이름
                          Text(
                            musicType.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 설명
                          Text(
                            musicType.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 스펙트럼 바
                          AnimatedBuilder(
                            animation: _barAnimation,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  _buildSpectrumBar(
                                    label: '에너지',
                                    leftLabel: '차분',
                                    rightLabel: '활발',
                                    score: widget.energyScore,
                                    animProgress: _barAnimation.value,
                                    color: const Color(0xFF6366F1),
                                    description: _getEnergyLabel(widget.energyScore),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSpectrumBar(
                                    label: '감성',
                                    leftLabel: '서정',
                                    rightLabel: '쿨',
                                    score: widget.moodScore,
                                    animProgress: _barAnimation.value,
                                    color: const Color(0xFFEC4899),
                                    description: _getMoodLabel(widget.moodScore),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    '감정에 맞는 음악을\n당신의 스타일로 추천해드릴게요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // 시작하기 버튼
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
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
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpectrumBar({
    required String label,
    required String leftLabel,
    required String rightLabel,
    required double score,
    required double animProgress,
    required Color color,
    required String description,
  }) {
    final animatedScore = score * animProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 바 배경
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // 채워진 부분
              FractionallySizedBox(
                widthFactor: animatedScore.clamp(0.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary.withAlpha(150),
              ),
            ),
            Text(
              rightLabel,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary.withAlpha(150),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
