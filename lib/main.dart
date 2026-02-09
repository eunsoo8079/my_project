import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'services/music_service.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

// 글로벌 네비게이터 키 (알림에서 화면 이동용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화 (에러 발생해도 앱은 실행)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();

    // 알림 클릭 시 RecordScreen으로 이동
    NotificationService.onNotificationTap = () {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const RecordScreen()),
      );
    };
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 후 권한 요청
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final notificationService = NotificationService();
      final granted = await notificationService.requestPermissions();

      if (granted) {
        final db = DatabaseService.instance;
        final enabled = await db.getSetting('notification_enabled');
        if (enabled == 'false') return;

        final timeStr = await db.getSetting('notification_time') ?? '21:00';
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        await notificationService.scheduleDailyNotification(hour, minute);
      }
    } catch (e) {
      debugPrint('Notification setup error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmotionProvider()..loadRecords()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider.value(value: MusicService()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MoodLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
