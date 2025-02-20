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
    primarySwatch: createMaterialColor(const Color(0xFF1F1F1F)), // 어두운 회색
    scaffoldBackgroundColor: const Color(0xFF121212), // 배경색 (다크 모드)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F), // 다크 모드 앱바 색상
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}
