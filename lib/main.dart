import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'services/notification_service.dart';

// 글로벌 네비게이터 키 (알림에서 화면 이동용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // 알림 클릭 시 RecordScreen으로 이동
  NotificationService.onNotificationTap = () {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const RecordScreen()),
    );
  };

  // 기본 알림 설정 (21:00)
  await notificationService.scheduleDailyNotification(21, 0);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmotionProvider()..loadRecords()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MoodLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: const CardThemeData(elevation: 2),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
