import 'package:http/http.dart' as http;
import 'splash/SplashPage.dart';
import 'package:flutter/material.dart';
import 'mobile_home_page.dart'; // 앱 전용 페이지
import 'web_home_page.dart'; // 웹 전용 페이지
import 'loginPge.dart'; // 통합된 로그인 페이지
import 'package:flutter/foundation.dart' show kIsWeb; // 웹 구분을 위한 kIsWeb 사용





void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강아지',
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFFFFF9C4)), // 기본 색상 설정
      ),
      // 통합된 로그인 페이지로 시작

      initialRoute: '/splash',

      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(), // 로그인 페이지 경로 추가
        '/homeApp': (context) => const MobileHomePage(), // 앱 전용 페이지
        '/homeWeb': (context) => const WebHomePage(), // 웹 전용 페이지
      },
      debugShowCheckedModeBanner: false,
    );
  }

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
}


