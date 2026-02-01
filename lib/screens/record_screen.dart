import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/emotion_button.dart';
import '../widgets/emotion_slider.dart';
import '../services/music_service.dart';
import '../theme/app_theme.dart';

class RecordScreen extends StatefulWidget {
  final EmotionRecord? existingRecord;

  const RecordScreen({super.key, this.existingRecord});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _contentController = TextEditingController();
  String? _selectedEmotion;
  double _intensity = 50;
  bool _isSaving = false;

  final List<String> _emotions = ['😊', '😢', '😡', '😌', '😰', '😑', '🤔'];

  bool get isEditMode => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _selectedEmotion = widget.existingRecord!.emotionType;
      _intensity = widget.existingRecord!.emotionIntensity.toDouble();
      _contentController.text = widget.existingRecord!.content ?? '';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('감정을 선택해주세요'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();

    try {
      if (isEditMode) {
        final updatedRecord = EmotionRecord(
          id: widget.existingRecord!.id,
          date: widget.existingRecord!.date,
          time:
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          emotionType: _selectedEmotion!,
          emotionIntensity: _intensity.round(),
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          createdAt: widget.existingRecord!.createdAt,
        );
        await context.read<EmotionProvider>().updateRecord(updatedRecord);
      } else {
        final record = EmotionRecord(
          date: now,
          time:
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          emotionType: _selectedEmotion!,
          emotionIntensity: _intensity.round(),
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          createdAt: now,
        );
        await context.read<EmotionProvider>().addRecord(record);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? '✅ 기록이 수정되었습니다!' : '✅ 기록이 저장되었습니다!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _playMusic() async {
    if (_selectedEmotion == null) return;
    final success = await MusicService().playMusic(_selectedEmotion!);
    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음악 재생에 실패했습니다')));
    }
  }

  Future<void> _snooze() async {
    final settingsProvider = context.read<SettingsProvider>();
    if (!settingsProvider.canSnooze) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오늘은 더 이상 미룰 수 없습니다')));
      return;
    }
    await settingsProvider.snooze();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('30분 후에 다시 알려드릴게요 (${settingsProvider.snoozeCount}/3)'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: _isSaving
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text('저장 중...', style: AppTextStyles.subtitle),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // 앱바
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        if (!isEditMode)
                          TextButton(
                            onPressed: settingsProvider.canSnooze
                                ? _snooze
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '미루기 (${settingsProvider.snoozeCount}/3)',
                                style: TextStyle(
                                  color: settingsProvider.canSnooze
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                      ],
                    ),

                    // 콘텐츠
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // 제목
                          Text(
                            isEditMode ? '기록 수정' : '오늘의 감정',
                            style: AppTextStyles.headline1,
                          ),
                          const SizedBox(height: 8),
                          Text('지금 기분이 어떠세요?', style: AppTextStyles.subtitle),

                          const SizedBox(height: 32),

                          // 감정 선택
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppDecorations.cardDecoration,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: _emotions.map((emotion) {
                                return EmotionButton(
                                  emoji: emotion,
                                  isSelected: _selectedEmotion == emotion,
                                  onTap: () => setState(
                                    () => _selectedEmotion = emotion,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 감정 강도
                          Text(
                            '감정의 강도',
                            style: AppTextStyles.headline2.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          EmotionSlider(
                            value: _intensity,
                            onChanged: (value) =>
                                setState(() => _intensity = value),
                          ),

                          const SizedBox(height: 24),

                          // 음악 버튼
                          GestureDetector(
                            onTap: _selectedEmotion != null ? _playMusic : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedEmotion != null
                                      ? AppColors.primary
                                      : Colors.grey.withAlpha(50),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_note_rounded,
                                    color: _selectedEmotion != null
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '감정에 맞는 음악 듣기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedEmotion != null
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 내용 입력
                          Text(
                            '오늘 있었던 일',
                            style: AppTextStyles.headline2.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '선택사항이에요',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _contentController,
                              maxLines: 5,
                              maxLength: 500,
                              decoration: InputDecoration(
                                hintText: '오늘 무슨 일이 있었나요?\n자유롭게 기록해보세요...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary.withAlpha(150),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 저장 버튼
                          GestureDetector(
                            onTap: _saveRecord,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration:
                                  AppDecorations.primaryButtonDecoration,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditMode
                                        ? Icons.check_rounded
                                        : Icons.save_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isEditMode ? '수정 완료' : '저장하기',
                                    style: AppTextStyles.button.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
