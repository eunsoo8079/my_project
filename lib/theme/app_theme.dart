import 'package:flutter/material.dart';

/// MoodLog 앱의 디자인 시스템
class AppColors {
  // 메인 레몬버터 팔레트
  static const Color primary = Color(0xFFFCE186); // 밝은 버터 노랑
  static const Color primaryLight = Color(0xFFFFF3D1); // 연한 버터
  static const Color primaryDark = Color(0xFFD4A832); // 깊은 골드

  // 숲 초록 (보조 - 짙은 톤)
  static const Color accent = Color(0xFF4A7C59); // 짙은 숲 초록

  // 단색 배경 (그라데이션 제거)
  static const Color background = Color(0xFFEFF6F0); // 아주 연한 초록
  static const Color cardBackground = Colors.white; // 순백

  // 감정별 색상
  static const Map<String, Color> emotionColors = {
    '😊': Color(0xFFFCE186), // 기쁨 - 버터 노랑
    '😢': Color(0xFF6BA3A0), // 슬픔 - 차분한 청록
    '😡': Color(0xFFEF5350), // 분노 - 빨강
    '😌': Color(0xFF4A7C59), // 평온 - 숲 초록
    '😰': Color(0xFFCE93D8), // 불안 - 보라
    '😑': Color(0xFF9CB5A0), // 무표정 - 세이지
    '🤔': Color(0xFFE8A849), // 생각 - 따뜻한 주황
  };

  // 보조 색상
  static const Color surface = Colors.white; // 순백민트 흰색
  static const Color textPrimary = Color(0xFF1A1A1A); // 진한 검정
  static const Color textSecondary = Color(0xFF3D6B4F); // 짙은 초록
  static const Color success = Color(0xFF4A7C59); // 짙은 숲 초록
  static const Color warning = Color(0xFFE8A849); // 따뜻한 주황

  // ── 하위호환: 기존 코드에서 gradient 참조하는 곳 대응 ──
  // 그라데이션 제거 → 단색 LinearGradient로 대체
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFCE186), Color(0xFFFCE186)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFF6F0), Color(0xFFEFF6F0)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Colors.white],
  );
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'BareunBatang',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: 'BareunBatang',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'BareunBatang',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'BareunBatang',
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'BareunBatang',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle number = TextStyle(
    fontFamily: 'BareunBatang',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}

class AppDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.accent.withAlpha(20),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.accent.withAlpha(60),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// 앱 전체 테마
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.amber,
    useMaterial3: true,
    fontFamily: 'BareunBatang',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.background,
    ),
    cardTheme: const CardThemeData(elevation: 2),
  );
}
