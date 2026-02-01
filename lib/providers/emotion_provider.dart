import 'package:flutter/material.dart';
import '../models/emotion_record.dart';
import '../services/database_service.dart';

class EmotionProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  List<EmotionRecord> _records = [];
  bool _isLoading = false;

  List<EmotionRecord> get records => _records;
  bool get isLoading => _isLoading;

  // 모든 기록 불러오기
  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await _db.getAllEmotions();
    } catch (e) {
      debugPrint('Error loading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 새 기록 추가
  Future<void> addRecord(EmotionRecord record) async {
    try {
      final id = await _db.insertEmotion(record);
      final newRecord = EmotionRecord(
        id: id,
        date: record.date,
        time: record.time,
        emotionType: record.emotionType,
        emotionIntensity: record.emotionIntensity,
        content: record.content,
        musicUrl: record.musicUrl,
        createdAt: record.createdAt,
      );
      _records.insert(0, newRecord);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding record: $e');
      rethrow;
    }
  }

  // 기록 수정
  Future<void> updateRecord(EmotionRecord record) async {
    try {
      await _db.updateEmotion(record);
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating record: $e');
      rethrow;
    }
  }

  // 기록 삭제
  Future<void> deleteRecord(int id) async {
    try {
      await _db.deleteEmotion(id);
      _records.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting record: $e');
      rethrow;
    }
  }

  // 오늘 기록 가져오기
  EmotionRecord? getTodayRecord() {
    final today = DateTime.now();
    try {
      return _records.firstWhere(
        (r) =>
            r.date.year == today.year &&
            r.date.month == today.month &&
            r.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  // 특정 날짜 기록 가져오기
  EmotionRecord? getRecordByDate(DateTime date) {
    try {
      return _records.firstWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // 연속 기록 일수 계산
  int getStreakCount() {
    if (_records.isEmpty) return 0;

    final sortedRecords = List<EmotionRecord>.from(_records)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var record in sortedRecords) {
      final diff = checkDate.difference(record.date).inDays;

      if (diff == 0 || diff == 1) {
        streak++;
        checkDate = record.date;
      } else {
        break;
      }
    }

    return streak;
  }
}
