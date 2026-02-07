import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 알림 클릭 시 호출될 콜백
  static void Function()? onNotificationTap;

  Future<void> initialize() async {
    try {
      // 타임존 초기화
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (e) {
      debugPrint('Timezone init error: $e');
    }

    // Android 알림 채널 생성
    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_mood',
      '일일 감정 기록',
      description: '매일 정해진 시간에 감정 기록을 알려드립니다',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
      'test_channel',
      '테스트 알림',
      description: '알림 테스트용 채널',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // 채널 등록
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(dailyChannel);
      await androidPlugin.createNotificationChannel(testChannel);
      debugPrint('Notification channels created');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    debugPrint('Notification service initialized');
  }

  // 알림 클릭 핸들러
  static void _onNotificationTap(NotificationResponse response) {
    if (onNotificationTap != null) {
      onNotificationTap!();
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final android = await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      final ios = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      final result = android ?? ios ?? false;
      debugPrint('Permission request result: $result');
      return result;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  Future<void> scheduleDailyNotification(int hour, int minute) async {
    try {
      final scheduledTime = _nextInstanceOfTime(hour, minute);

      await _notifications.zonedSchedule(
        0,
        '오늘 기분이 어때요? 😊',
        '감정을 기록하고 음악을 들어보세요',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_mood',
            '일일 감정 기록',
            channelDescription: '매일 정해진 시간에 감정 기록을 알려드립니다',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('[Notification] Schedule ERROR: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
