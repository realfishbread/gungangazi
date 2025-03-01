import 'package:gungangazi/screen/home/web_home_page.dart';
import 'splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'screen/home/mobile_home_page.dart'; // 앱 전용 페이지
import 'screen/auth/login_page.dart'; // 통합된 로그인 페이지
import 'config/theme.dart'; // 테마 파일 import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gungangazi/screen/character/character_status.dart';
import 'repositories/status/character_repository.dart';

void main() {
  runApp(
 MultiProvider(
      providers: [
        // 1️⃣ CharacterRepository를 먼저 등록
        Provider<CharacterRepository>(
          create: (_) => CharacterRepository(),
        ),

        // 2️⃣ CharacterStatus를 등록 + CharacterRepository 주입
        ChangeNotifierProvider<CharacterStatus>(
          create: (context) => CharacterStatus(
            repository: context.read<CharacterRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
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


