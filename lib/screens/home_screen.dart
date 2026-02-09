import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_music_player.dart';
import 'record_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          CalendarScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 항상 표시되는 미니 뮤직 플레이어
          const MiniMusicPlayer(),
          // 네비게이션 바
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: '캘린더',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: '통계',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: '설정',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final todayRecord = emotionProvider.getTodayRecord();
    final streakCount = emotionProvider.getStreakCount();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안녕하세요! 👋',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      const Text('MoodLog', style: AppTextStyles.headline1),
                    ],
                  ),
                  // 연속 기록 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withAlpha(50),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.warning,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$streakCount일',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 메인 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: AppDecorations.cardDecoration,
                child: Column(
                  children: [
                    if (todayRecord != null) ...[
                      // 오늘 기록 있음
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              AppColors.emotionColors[todayRecord.emotionType]
                                  ?.withAlpha(30) ??
                              AppColors.primaryLight.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          todayRecord.emotionType,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('오늘의 감정', style: AppTextStyles.subtitle),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '강도 ${todayRecord.emotionIntensity}/100',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ] else ...[
                      // 아직 기록 없음
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '오늘의 감정을\n기록해보세요',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline2,
                      ),
                      const SizedBox(height: 12),
                      Text('하루를 돌아보며 감정을 정리해요', style: AppTextStyles.subtitle),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 기록 버튼
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecordScreen(existingRecord: todayRecord),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: AppDecorations.primaryButtonDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        todayRecord != null
                            ? Icons.edit_rounded
                            : Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        todayRecord != null ? '오늘 기록 수정하기' : '오늘 기분 기록하기',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 빠른 통계
              Text(
                '이번 주 기록',
                style: AppTextStyles.headline2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildWeeklyPreview(emotionProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPreview(EmotionProvider provider) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) {
          final record = provider.getRecordByDate(day);
          final isToday =
              day.day == now.day &&
              day.month == now.month &&
              day.year == now.year;

          return Column(
            children: [
              Text(
                ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1],
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withAlpha(30)
                      : record != null
                      ? AppColors.emotionColors[record.emotionType]?.withAlpha(
                          30,
                        )
                      : Colors.grey.withAlpha(20),
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: record != null
                      ? Text(
                          record.emotionType,
                          style: const TextStyle(fontSize: 18),
                        )
                      : Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
