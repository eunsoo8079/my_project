import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final records = emotionProvider.records;

    // 최근 7일 기록
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekRecords = records.where((r) => r.date.isAfter(weekAgo)).toList();

    // 감정별 카운트
    final Map<String, int> emotionCounts = {};
    for (var record in records) {
      emotionCounts[record.emotionType] =
          (emotionCounts[record.emotionType] ?? 0) + 1;
    }

    // TOP 3
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sortedEmotions.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 연속 기록
          _buildStatCard(
            '연속 기록 일수',
            '${emotionProvider.getStreakCount()}일',
            Icons.local_fire_department,
            Colors.orange,
          ),

          const SizedBox(height: 16),

          // 이번 주 기록
          _buildStatCard(
            '이번 주 기록',
            '${weekRecords.length}개',
            Icons.calendar_today,
            Colors.blue,
          ),

          const SizedBox(height: 16),

          // 전체 기록
          _buildStatCard(
            '전체 기록',
            '${records.length}개',
            Icons.edit_note,
            Colors.green,
          ),

          const SizedBox(height: 24),

          // TOP 3 감정
          const Text(
            'TOP 3 감정',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (top3.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    '아직 기록이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ...top3.asMap().entries.map((entry) {
              final index = entry.key;
              final emotion = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    emotion.key,
                    style: const TextStyle(fontSize: 32),
                  ),
                  trailing: Text(
                    '${emotion.value}번',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}
