import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // 감정별 로컬 음악 파일 매핑
  static const Map<String, String> _musicFiles = {
    '😊': 'Sound/Happy.mp3', // 기쁨
    '😢': 'Sound/Sad.mp3', // 슬픔
    '😡': 'Sound/Angry.mp3', // 분노
    '😌': 'Sound/Relax.mp3', // 평온
    '😰': 'Sound/Relax.mp3', // 불안 -> 평온한 음악
    '😑': 'Sound/Absurd.mp3', // 무표정
    '🤔': 'Sound/Curious.mp3', // 궁금
  };

  bool get isPlaying => _isPlaying;

  Future<bool> playMusic(String emotion) async {
    final musicFile = _musicFiles[emotion];
    if (musicFile == null) return false;

    try {
      // 이미 재생 중이면 중지
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // 로컬 에셋에서 음악 재생
      await _audioPlayer.play(AssetSource(musicFile));
      _isPlaying = true;

      // 재생 완료 시 상태 업데이트
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });

      return true;
    } catch (e) {
      debugPrint('Error playing music: $e');
      return false;
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
