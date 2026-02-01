import 'package:url_launcher/url_launcher.dart';

class MusicService {
  // 감정별 YouTube 플레이리스트 URL
  // TODO: 실제 플레이리스트로 교체하세요
  static const Map<String, String> _playlists = {
    '😊':
        'https://youtube.com/playlist?list=PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI', // Happy
    '😢':
        'https://youtube.com/playlist?list=PLFgquLnL59akA2PflFpeQG9L01VFg90wS', // Sad
    '😡':
        'https://youtube.com/playlist?list=PLFgquLnL59an0KfeviQPIvNAXy0dFOKy4', // Angry/Intense
    '😌':
        'https://youtube.com/playlist?list=PLFgquLnL59alcyR5Alj1kdVd00gVXY6HL', // Calm
    '😰':
        'https://youtube.com/playlist?list=PLFgquLnL59alcyR5Alj1kdVd00gVXY6HL', // Anxious (Calm)
    '😑':
        'https://youtube.com/playlist?list=PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI', // Neutral (Happy)
    '🤔':
        'https://youtube.com/playlist?list=PLFgquLnL59amY77GhhSOZ7bDELKwmlA3X', // Confused (Focus)
  };

  Future<bool> playMusic(String emotion) async {
    final url = _playlists[emotion];
    if (url == null) return false;

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error launching music: $e');
      return false;
    }
  }

  String? getPlaylistUrl(String emotion) {
    return _playlists[emotion];
  }
}
