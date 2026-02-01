import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/emotion_button.dart';
import '../widgets/emotion_slider.dart';
import '../services/music_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _contentController = TextEditingController();
  String? _selectedEmotion;
  double _intensity = 50;
  bool _isSaving = false;

  final List<String> _emotions = ['😊', '😢', '😡', '😌', '😰', '😑', '🤔'];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_selectedEmotion == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('감정을 선택해주세요')));
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
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

    try {
      await context.read<EmotionProvider>().addRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 기록이 저장되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
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
          content: Text(
            '30분 후에 다시 알려드릴게요 (남은 미루기: ${settingsProvider.snoozeCount}/3)',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 감정 기록'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: settingsProvider.canSnooze ? _snooze : null,
            child: Text(
              '미루기 (${settingsProvider.snoozeCount}/3)',
              style: TextStyle(
                color: settingsProvider.canSnooze
                    ? Colors.white
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 감정 선택
                  const Text(
                    '오늘 기분이 어때요?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _emotions.map((emotion) {
                      return EmotionButton(
                        emoji: emotion,
                        isSelected: _selectedEmotion == emotion,
                        onTap: () => setState(() => _selectedEmotion = emotion),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // 감정 강도
                  const Text(
                    '감정의 강도',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  EmotionSlider(
                    value: _intensity,
                    onChanged: (value) => setState(() => _intensity = value),
                  ),

                  const SizedBox(height: 32),

                  // 음악 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _selectedEmotion != null ? _playMusic : null,
                      icon: const Icon(Icons.music_note),
                      label: const Text('감정에 맞는 음악 듣기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 내용 입력
                  const Text(
                    '오늘 있었던 일 (선택)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '오늘 무슨 일이 있었나요?\n자유롭게 기록해보세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        '저장하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
