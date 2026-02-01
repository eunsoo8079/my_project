import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class SettingsProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;

  String _notificationTime = '21:00';
  bool _notificationEnabled = true;
  int _snoozeCount = 3;
  String? _lastSnoozeDate;

  String get notificationTime => _notificationTime;
  bool get notificationEnabled => _notificationEnabled;
  int get snoozeCount => _snoozeCount;
  bool get canSnooze => _snoozeCount > 0;

  // 설정 불러오기
  Future<void> loadSettings() async {
    _notificationTime = await _db.getSetting('notification_time') ?? '21:00';
    _notificationEnabled =
        await _db.getSetting('notification_enabled') != 'false';
    _snoozeCount =
        int.tryParse(await _db.getSetting('snooze_count') ?? '3') ?? 3;
    _lastSnoozeDate = await _db.getSetting('last_snooze_date');

    // 날짜가 바뀌면 미루기 횟수 리셋
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_lastSnoozeDate != today) {
      _snoozeCount = 3;
      await _db.setSetting('snooze_count', '3');
      await _db.setSetting('last_snooze_date', today);
    }

    notifyListeners();
  }

  // 미루기
  Future<void> snooze() async {
    if (_snoozeCount > 0) {
      _snoozeCount--;
      await _db.setSetting('snooze_count', _snoozeCount.toString());

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _db.setSetting('last_snooze_date', today);

      notifyListeners();
    }
  }

  // 알림 시간 변경
  Future<void> setNotificationTime(String time) async {
    _notificationTime = time;
    await _db.setSetting('notification_time', time);
    notifyListeners();
  }

  // 알림 켜기/끄기
  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
    await _db.setSetting('notification_enabled', enabled.toString());
    notifyListeners();
  }
}
