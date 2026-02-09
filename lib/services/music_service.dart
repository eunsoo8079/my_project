import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService extends ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;
  String? _currentEmotion;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _dismissTimer;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _completeSub;

  // 감정별 로컬 음악 파일 매핑
  static const Map<String, String> _musicFiles = {
    '😊': 'Sound/Happy.mp3',
    '😢': 'Sound/Sad.mp3',
    '😡': 'Sound/Angry.mp3',
    '😌': 'Sound/Relax.mp3',
    '😰': 'Sound/Relax.mp3',
    '😑': 'Sound/Absurd.mp3',
    '🤔': 'Sound/Curious.mp3',
  };

  static const Map<String, String> _emotionNames = {
    '😊': '기쁨',
    '😢': '슬픔',
    '😡': '분노',
    '😌': '평온',
    '😰': '불안',
    '😑': '무표정',
    '🤔': '궁금',
  };

  static const List<String> _emotionOrder = [
    '😊', '😢', '😡', '😌', '😰', '😑', '🤔',
  ];

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  String? get currentEmotion => _currentEmotion;
  Duration get position => _position;
  Duration get duration => _duration;
  String get currentEmotionName => _emotionNames[_currentEmotion] ?? '';
  String get currentMusicTitle =>
      _currentEmotion != null ? '$currentEmotionName 음악' : '';
  bool get hasActiveSession => _currentEmotion != null;

  Future<bool> playMusic(String emotion) async {
    final musicFile = _musicFiles[emotion];
    if (musicFile == null) return false;

    try {
      _dismissTimer?.cancel();
      _dismissTimer = null;
      await _cancelSubscriptions();
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();

      _audioPlayer = AudioPlayer();

      _positionSub = _audioPlayer!.onPositionChanged.listen((pos) {
        _position = pos;
        notifyListeners();
      });

      _durationSub = _audioPlayer!.onDurationChanged.listen((dur) {
        _duration = dur;
        notifyListeners();
      });

      _completeSub = _audioPlayer!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _isPaused = false;
        _position = _duration; // 끝까지 도달 표시
        notifyListeners();

        // 2초 후 세션 정리 (자연스러운 사라짐)
        _dismissTimer = Timer(const Duration(seconds: 2), () {
          _currentEmotion = null;
          _position = Duration.zero;
          _duration = Duration.zero;
          _dismissTimer = null;
          notifyListeners();
        });

        debugPrint('Music playback completed');
      });

      _audioPlayer!.onLog.listen((msg) {
        debugPrint('AudioPlayer log: $msg');
      });

      debugPrint('Playing music: $musicFile');
      await _audioPlayer!.setSource(AssetSource(musicFile));
      await _audioPlayer!.resume();

      _isPlaying = true;
      _isPaused = false;
      _currentEmotion = emotion;
      _position = Duration.zero;
      notifyListeners();
      debugPrint('Music started playing');

      return true;
    } catch (e) {
      debugPrint('Error playing music: $e');
      _isPlaying = false;
      _isPaused = false;
      _currentEmotion = null;
      notifyListeners();
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

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pauseMusic();
    } else if (_currentEmotion != null) {
      await resumeMusic();
    }
  }

  Future<void> stopMusic() async {
    try {
      _dismissTimer?.cancel();
      _dismissTimer = null;
      await _cancelSubscriptions();
      await _audioPlayer?.stop();
      _isPlaying = false;
      _isPaused = false;
      _currentEmotion = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();
      debugPrint('Music stopped');
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _audioPlayer?.pause();
      _isPlaying = false;
      _isPaused = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      _dismissTimer?.cancel();
      _dismissTimer = null;
      await _audioPlayer?.resume();
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  Future<void> skipToNext() async {
    if (_currentEmotion == null) return;
    final currentIndex = _emotionOrder.indexOf(_currentEmotion!);
    final nextIndex = (currentIndex + 1) % _emotionOrder.length;
    await playMusic(_emotionOrder[nextIndex]);
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer?.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _completeSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _completeSub = null;
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _cancelSubscriptions();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _isPaused = false;
    _currentEmotion = null;
    super.dispose();
  }
}
