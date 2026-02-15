import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ItunesService {
  static const _baseUrl = 'https://itunes.apple.com';

  /// trackId로 미리듣기 URL + 메타데이터 가져오기
  static Future<Map<String, dynamic>?> getTrack(int trackId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lookup?id=$trackId&country=KR'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[0] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('iTunes lookup error: $e');
    }
    return null;
  }

  /// trackId로 미리듣기 URL만 가져오기
  static Future<String?> getPreviewUrl(int trackId) async {
    final track = await getTrack(trackId);
    return track?['previewUrl'] as String?;
  }

  /// 검색 (큐레이션 목록 만들 때 사용)
  static Future<List<Map<String, dynamic>>> search(
    String query, {
    int limit = 5,
  }) async {
    try {
      final url = '$_baseUrl/search'
          '?term=${Uri.encodeComponent(query)}'
          '&country=KR&media=music&entity=song&limit=$limit';
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('iTunes search error: $e');
    }
    return [];
  }
}
