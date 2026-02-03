import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  String? _currentEmotion;

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
  String? get currentEmotion => _currentEmotion;

  Future<bool> playMusic(String emotion) async {
    final musicFile = _musicFiles[emotion];
    if (musicFile == null) return false;

    try {
      // 기존 플레이어 정리
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();

      // 새 플레이어 생성
      _audioPlayer = AudioPlayer();

      // 재생 완료 시 상태 업데이트
      _audioPlayer!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentEmotion = null;
        debugPrint('Music playback completed');
      });

      // 에러 처리
      _audioPlayer!.onLog.listen((msg) {
        debugPrint('AudioPlayer log: $msg');
      });

      // 로컬 에셋에서 음악 재생
      debugPrint('Playing music: $musicFile');
      await _audioPlayer!.setSource(AssetSource(musicFile));
      await _audioPlayer!.resume();

      _isPlaying = true;
      _currentEmotion = emotion;
      debugPrint('Music started playing');

      return true;
    } catch (e) {
      debugPrint('Error playing music: $e');
      _isPlaying = false;
      _currentEmotion = null;
      return false;
    }
  }

  Future<void> toggleMusic(String emotion) async {
    if (_isPlaying && _currentEmotion == emotion) {
      await stopMusic();
    } else {
      await playMusic(emotion);
    }
  }

  Future<void> stopMusic() async {
    try {
      await _audioPlayer?.stop();
      _isPlaying = false;
      _currentEmotion = null;
      debugPrint('Music stopped');
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _audioPlayer?.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      await _audioPlayer?.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _currentEmotion = null;
  }
}
