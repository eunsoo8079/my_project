import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/curated_tracks.dart';
import 'database_service.dart';
import 'itunes_service.dart';

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
  double? _energyScore;
  String? _trackName;
  String? _artistName;
  bool _isStreaming = false; // true = iTunes preview, false = local file

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _completeSub;

  // 감정별 기본 음악 파일 (폴백용)
  static const Map<String, String> _defaultMusicFiles = {
    '😊': 'Sound/Happy.mp3',
    '😢': 'Sound/Sad.mp3',
    '😡': 'Sound/Angry.mp3',
    '😌': 'Sound/Relax.mp3',
    '😰': 'Sound/Relax.mp3',
    '😑': 'Sound/Absurd.mp3',
    '🤔': 'Sound/Curious.mp3',
  };

  // 감정 → 파일 이름 매핑 (유형별 폴더 내에서 사용)
  static const Map<String, String> _emotionFileNames = {
    '😊': 'happy.mp3',
    '😢': 'sad.mp3',
    '😡': 'angry.mp3',
    '😌': 'relax.mp3',
    '😰': 'anxious.mp3',
    '😑': 'neutral.mp3',
    '🤔': 'curious.mp3',
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
  String get currentMusicTitle {
    if (_trackName != null && _artistName != null) {
      return '$_artistName - $_trackName';
    }
    return _currentEmotion != null ? '$currentEmotionName 음악' : '';
  }
  bool get hasActiveSession => _currentEmotion != null;
  bool get isStreaming => _isStreaming;
  double? get energyScore => _energyScore;

  /// DB에서 에너지 점수 로드 (0.0~1.0)
  Future<void> loadMusicType() async {
    try {
      final scoreStr = await DatabaseService.instance.getSetting('energy_score');
      if (scoreStr != null) {
        _energyScore = double.parse(scoreStr);
        debugPrint('Energy score loaded: $_energyScore');
      }
    } catch (e) {
      debugPrint('Error loading energy score: $e');
    }
  }

  /// 감정에 맞는 음악 파일 경로 결정 (에너지 기반 → 기본 폴백)
  Future<String> _getMusicPath(String emotion) async {
    // 에너지 점수가 있으면 calm/energetic 폴더에서 찾기
    if (_energyScore != null) {
      final folder = _energyScore! >= 0.5 ? 'energetic' : 'calm';
      final emotionFile = _emotionFileNames[emotion];
      if (emotionFile != null) {
        final typedPath = 'Sound/$folder/$emotionFile';
        if (await _assetExists(typedPath)) {
          debugPrint('Using $folder music: $typedPath');
          return typedPath;
        }
        debugPrint('$folder music not found, falling back: $typedPath');
      }
    }

    // 폴백: 기본 음악 파일
    return _defaultMusicFiles[emotion] ?? 'Sound/Happy.mp3';
  }

  /// 에셋 파일 존재 여부 확인
  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load('assets/$path');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// iTunes 미리듣기 URL 가져오기 (큐레이션 트랙에서 랜덤 선택)
  Future<String?> _getPreviewUrl(String emotion) async {
    if (_energyScore == null) return null;
    await CuratedTracks.load();
    final trackIds = CuratedTracks.getTracks(_energyScore!, emotion);
    if (trackIds.isEmpty) return null;

    // 랜덤으로 곡 선택
    final trackId = trackIds[Random().nextInt(trackIds.length)];
    final track = await ItunesService.getTrack(trackId);
    if (track != null) {
      _trackName = track['trackName'] as String?;
      _artistName = track['artistName'] as String?;
      return track['previewUrl'] as String?;
    }
    return null;
  }

  Future<bool> playMusic(String emotion) async {
    try {
      // 에너지 점수가 아직 로드되지 않았으면 로드
      if (_energyScore == null) {
        await loadMusicType();
      }

      _dismissTimer?.cancel();
      _dismissTimer = null;
      await _cancelSubscriptions();
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();

      _audioPlayer = AudioPlayer();
      _trackName = null;
      _artistName = null;

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
        _position = _duration;
        notifyListeners();

        _dismissTimer = Timer(const Duration(seconds: 2), () {
          _currentEmotion = null;
          _trackName = null;
          _artistName = null;
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

      // 1순위: iTunes 미리듣기 (온라인)
      final previewUrl = await _getPreviewUrl(emotion);
      if (previewUrl != null) {
        debugPrint('Playing iTunes preview: $previewUrl');
        await _audioPlayer!.setSource(UrlSource(previewUrl));
        _isStreaming = true;
      } else {
        // 2순위: 로컬 파일 (오프라인 폴백)
        final musicFile = await _getMusicPath(emotion);
        debugPrint('Playing local music: $musicFile');
        await _audioPlayer!.setSource(AssetSource(musicFile));
        _isStreaming = false;
      }
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
      _trackName = null;
      _artistName = null;
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

  /// 음악 성향 변경 시 호출 (재설문 후)
  void refreshMusicType() {
    _energyScore = null; // 다음 재생 시 다시 로드
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
