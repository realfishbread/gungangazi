import 'package:flutter/material.dart';

/// 🎨 단색(Color)을 MaterialColor로 변환하는 함수
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

/// 🎨 앱 테마 설정
class AppTheme {
  /// 🌞 **라이트 테마**
  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'NanumGothic',
    primarySwatch: createMaterialColor(const Color(0xFFFFF9C4)), // 밝은 노란색
    scaffoldBackgroundColor: Colors.white, // 배경색
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF9C4),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );

  /// 🌙 **다크 테마**
  static final ThemeData darkTheme = ThemeData(
  fontFamily: 'NanumGothic',
  primarySwatch: createMaterialColor(const Color(0xFFB39DDB)), // 부드러운 포인트 컬러
  scaffoldBackgroundColor: const Color(0xFF1E1E1E), // 거의 블랙에 가까운 다크 그레이
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2C), // 살짝 밝은 앱바
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.87)), // 강조 텍스트
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)), // 일반 텍스트
    bodySmall: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.38)), // 비활성 텍스트
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
  dividerColor: Colors.grey.shade700,
  cardColor: const Color(0xFF2A2A2A), // Elevated surface 표현
  dialogBackgroundColor: const Color(0xFF2E2E2E),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFB39DDB),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
}
