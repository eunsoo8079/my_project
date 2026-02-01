import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/emotion_provider.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _selectTime(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    final currentTime = provider.notificationTime.split(':');

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(currentTime[0]),
        minute: int.parse(currentTime[1]),
      ),
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await provider.setNotificationTime(newTime);

      // 알림 재설정
      await NotificationService().scheduleDailyNotification(
        picked.hour,
        picked.minute,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알림 시간이 $newTime로 설정되었습니다')));
      }
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 기록이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = await DatabaseService.instance.database;
      await db.delete('emotions');
      await db.delete('settings');

      if (context.mounted) {
        context.read<EmotionProvider>().loadRecords();
        context.read<SettingsProvider>().loadSettings();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('데이터가 초기화되었습니다')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('알림 시간'),
            subtitle: Text(provider.notificationTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectTime(context),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('알림 켜기'),
            value: provider.notificationEnabled,
            onChanged: (value) async {
              await provider.setNotificationEnabled(value);

              if (value) {
                final time = provider.notificationTime.split(':');
                await NotificationService().scheduleDailyNotification(
                  int.parse(time[0]),
                  int.parse(time[1]),
                );
              } else {
                await NotificationService().cancelAllNotifications();
              }
            },
          ),

          const Divider(),

          const ListTile(
            title: Text(
              '데이터',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('데이터 초기화'),
            subtitle: const Text('모든 기록을 삭제합니다'),
            onTap: () => _resetData(context),
          ),

          const Divider(),

          const ListTile(
            title: Text(
              '정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('버전'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
