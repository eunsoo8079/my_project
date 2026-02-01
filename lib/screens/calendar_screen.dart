import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../theme/app_theme.dart';
import 'record_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();

    final Map<DateTime, String> emotionMap = {};
    for (var record in emotionProvider.records) {
      final date = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      emotionMap[date] = record.emotionType;
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('캘린더', style: AppTextStyles.headline1),
                  const SizedBox(height: 8),
                  Text('나의 감정 여정을 돌아봐요', style: AppTextStyles.subtitle),
                ],
              ),
            ),

            // 캘린더
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.cardDecoration,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTextStyles.headline2.copyWith(
                    fontSize: 18,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.red.shade300),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final normalizedDay = DateTime(
                      day.year,
                      day.month,
                      day.day,
                    );
                    final emotion = emotionMap[normalizedDay];

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: emotion != null
                          ? BoxDecoration(
                              color: AppColors.emotionColors[emotion]
                                  ?.withAlpha(40),
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Center(
                        child: emotion != null
                            ? Text(
                                emotion,
                                style: const TextStyle(fontSize: 18),
                              )
                            : Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final normalizedDay = DateTime(
                      day.year,
                      day.month,
                      day.day,
                    );
                    final emotion = emotionMap[normalizedDay];

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: emotion != null
                            ? Text(
                                emotion,
                                style: const TextStyle(fontSize: 18),
                              )
                            : Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 선택된 날짜의 기록
            if (_selectedDay != null)
              Expanded(
                child: _buildRecordDetail(emotionProvider, _selectedDay!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetail(EmotionProvider provider, DateTime selectedDay) {
    EmotionRecord? record;
    try {
      record = provider.records.firstWhere(
        (r) => isSameDay(r.date, selectedDay),
      );
    } catch (e) {
      record = null;
    }

    if (record == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: AppDecorations.cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text('이 날은 기록이 없습니다', style: AppTextStyles.subtitle),
          ],
        ),
      );
    }

    final emotionColor =
        AppColors.emotionColors[record.emotionType] ?? AppColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: AppDecorations.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: emotionColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.emotionType,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.date.year}년 ${record.date.month}월 ${record.date.day}일',
                          style: AppTextStyles.headline2.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(record.time, style: AppTextStyles.subtitle),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: emotionColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '강도 ${record.emotionIntensity}/100',
                            style: TextStyle(
                              color: emotionColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (record.content != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(record.content!, style: AppTextStyles.body),
                ),
              ],

              const SizedBox(height: 20),

              // 수정/삭제 버튼
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecordScreen(existingRecord: record),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '수정',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _deleteRecord(record!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '삭제',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRecord(EmotionRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<EmotionProvider>().deleteRecord(record.id!);
        setState(() => _selectedDay = null);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('기록이 삭제되었습니다'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
        }
      }
    }
  }
}
