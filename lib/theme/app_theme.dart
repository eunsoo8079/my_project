import 'package:flutter/material.dart';

/// MoodLog 앱의 디자인 시스템
class AppColors {
  // 메인 하늘색 팔레트
  static const Color primary = Color(0xFF4FC3F7); // 밝은 하늘색
  static const Color primaryLight = Color(0xFF81D4FA); // 연한 하늘색
  static const Color primaryDark = Color(0xFF29B6F6); // 진한 하늘색

  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF5F9FF)],
  );

  // 감정별 색상
  static const Map<String, Color> emotionColors = {
    '😊': Color(0xFFFFD54F), // 기쁨 - 노랑
    '😢': Color(0xFF90CAF9), // 슬픔 - 파랑
    '😡': Color(0xFFEF5350), // 분노 - 빨강
    '😌': Color(0xFF81C784), // 평온 - 초록
    '😰': Color(0xFFCE93D8), // 불안 - 보라
    '😑': Color(0xFFBDBDBD), // 무표정 - 회색
    '🤔': Color(0xFFFFB74D), // 생각 - 주황
  };

  // 보조 색상
  static const Color surface = Color(0xFFF8FBFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
}

class AppTextStyles {
  // 로컬 Gaegu 폰트 적용
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
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(25),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(100),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// 앱 전체 테마
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    fontFamily: 'BareunBatang',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(elevation: 2),
  );
}
