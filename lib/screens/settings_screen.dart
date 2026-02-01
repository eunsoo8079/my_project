import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/emotion_provider.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await provider.setNotificationTime(newTime);
      await NotificationService().scheduleDailyNotification(
        picked.hour,
        picked.minute,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 시간이 $newTime로 설정되었습니다'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('데이터 초기화'),
          ],
        ),
        content: const Text('모든 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'),
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

    if (confirmed == true) {
      final db = await DatabaseService.instance.database;
      await db.delete('emotions');
      await db.delete('settings');

      if (context.mounted) {
        context.read<EmotionProvider>().loadRecords();
        context.read<SettingsProvider>().loadSettings();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('데이터가 초기화되었습니다'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('설정', style: AppTextStyles.headline1),
              const SizedBox(height: 8),
              Text('앱을 나만의 스타일로', style: AppTextStyles.subtitle),

              const SizedBox(height: 32),

              // 알림 설정
              _SectionTitle(title: '알림', icon: Icons.notifications_rounded),
              const SizedBox(height: 16),

              Container(
                decoration: AppDecorations.cardDecoration,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.access_time_rounded,
                      iconColor: AppColors.primary,
                      title: '알림 시간',
                      subtitle: provider.notificationTime,
                      onTap: () => _selectTime(context),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: Colors.grey.withAlpha(30),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppColors.primary,
                      title: '알림 받기',
                      subtitle: provider.notificationEnabled ? '켜짐' : '꺼짐',
                      trailing: Switch(
                        value: provider.notificationEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (value) async {
                          await provider.setNotificationEnabled(value);
                          if (value) {
                            final time = provider.notificationTime.split(':');
                            await NotificationService()
                                .scheduleDailyNotification(
                                  int.parse(time[0]),
                                  int.parse(time[1]),
                                );
                          } else {
                            await NotificationService()
                                .cancelAllNotifications();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 데이터
              _SectionTitle(title: '데이터', icon: Icons.storage_rounded),
              const SizedBox(height: 16),

              Container(
                decoration: AppDecorations.cardDecoration,
                child: _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: Colors.red,
                  title: '데이터 초기화',
                  subtitle: '모든 기록 삭제',
                  onTap: () => _resetData(context),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),

              const SizedBox(height: 32),

              // 정보
              _SectionTitle(title: '정보', icon: Icons.info_rounded),
              const SizedBox(height: 16),

              Container(
                decoration: AppDecorations.cardDecoration,
                child: _SettingsTile(
                  icon: Icons.verified_rounded,
                  iconColor: AppColors.success,
                  title: '버전',
                  subtitle: 'MoodLog v1.0.0',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '최신',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 만든 사람
              Center(
                child: Text(
                  'Made with 💙',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
