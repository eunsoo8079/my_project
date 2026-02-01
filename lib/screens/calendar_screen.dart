import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';

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

    // 날짜별 감정 매핑
    final Map<DateTime, String> emotionMap = {};
    for (var record in emotionProvider.records) {
      final date = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      emotionMap[date] = record.emotionType;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('감정 캘린더'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
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
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final emotion = emotionMap[normalizedDay];

                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}', style: const TextStyle(fontSize: 14)),
                      if (emotion != null)
                        Text(emotion, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final emotion = emotionMap[normalizedDay];

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (emotion != null)
                        Text(emotion, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 선택된 날짜의 기록
          if (_selectedDay != null)
            Expanded(child: _buildRecordDetail(emotionProvider, _selectedDay!)),
        ],
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
      return const Center(
        child: Text('이 날은 기록이 없습니다', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    record.emotionType,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.date.year}년 ${record.date.month}월 ${record.date.day}일',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          record.time,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '강도: ${record.emotionIntensity}/100',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (record.content != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(record.content!, style: const TextStyle(fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
