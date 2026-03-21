import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final records = emotionProvider.records;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekRecords = records.where((r) => r.date.isAfter(weekAgo)).toList();

    final Map<String, int> emotionCounts = {};
    for (var record in records) {
      emotionCounts[record.emotionType] =
          (emotionCounts[record.emotionType] ?? 0) + 1;
    }

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sortedEmotions.take(3).toList();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('통계', style: AppTextStyles.headline1),
              const SizedBox(height: 8),
              Text('나의 감정 기록을 한눈에', style: AppTextStyles.subtitle),

              const SizedBox(height: 32),

              // 통계 카드들
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.warning,
                      title: '연속 기록',
                      value: '${emotionProvider.getStreakCount()}일',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppColors.primary,
                      title: '이번 주',
                      value: '${weekRecords.length}개',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _StatCard(
                icon: Icons.edit_note_rounded,
                iconColor: AppColors.success,
                title: '전체 기록',
                value: '${records.length}개',
                fullWidth: true,
              ),

              const SizedBox(height: 32),

              // TOP 3 감정
              Text(
                'TOP 3 감정',
                style: AppTextStyles.headline2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),

              if (top3.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: AppDecorations.cardDecoration,
                  child: Column(
                    children: [
                      Icon(
                        Icons.sentiment_neutral_rounded,
                        size: 60,
                        color: AppColors.textSecondary.withAlpha(100),
                      ),
                      const SizedBox(height: 16),
                      Text('아직 기록이 없습니다', style: AppTextStyles.subtitle),
                    ],
                  ),
                )
              else
                ...top3.asMap().entries.map((entry) {
                  final index = entry.key;
                  final emotion = entry.value;
                  final emotionColor =
                      AppColors.emotionColors[emotion.key] ?? AppColors.primary;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppDecorations.cardDecoration,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getRankColor(index),
                              _getRankColor(index).withAlpha(180),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _getRankColor(index).withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: emotionColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              emotion.key,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getEmotionName(emotion.key),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${emotion.value}번 기록',
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: emotionColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${((emotion.value / records.length) * 100).round()}%',
                          style: TextStyle(
                            color: emotionColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmotionName(String emoji) {
    const names = {
      '😊': '기쁨',
      '😢': '슬픔',
      '😡': '분노',
      '😌': '평온',
      '😰': '불안',
      '😑': '무표정',
      '🤔': '생각',
    };
    return names[emoji] ?? '감정';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFD700); // 금
      case 1:
        return const Color(0xFFC0C0C0); // 은
      case 2:
        return const Color(0xFFCD7F32); // 동
      default:
        return AppColors.primary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.headline2.copyWith(fontSize: 24),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
