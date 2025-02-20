import 'package:gungangazi/screen/home/web_home_page.dart';
import 'splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'screen/home/mobile_home_page.dart'; // 앱 전용 페이지
import 'screen/auth/login_page.dart'; // 통합된 로그인 페이지
import 'config/theme.dart'; // 테마 파일 import

void main() {
  runApp(
      MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강하지',
      theme: AppTheme.lightTheme,  // 🌞 기본 테마 (라이트)
      darkTheme: AppTheme.darkTheme, // 🌙 다크 테마 추가
      themeMode: ThemeMode.system,  // 🔄 시스템 설정에 따라 자동 변경
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(), // 로그인 페이지 경로 추가
        '/WebHome': (context) => const WebHomePage(),
        '/homeApp': (context) => const MobileHomePage(), // 앱 전용 페이지
        
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


