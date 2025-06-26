import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gungangazi/screen/character/character_status.dart';
import 'package:gungangazi/screen/home/web_home_page.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart'; // 테마 파일 import
import 'core_services/dio_service.dart';
import 'core_services/token_service.dart';
import 'repositories/status/character_repository.dart';
import 'screen/auth/login_page.dart'; // 통합된 로그인 페이지
import 'screen/home/mobile_home_page.dart'; // 앱 전용 페이지
import 'splash/splash_page.dart';
import 'view_model/character_view_model.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CharacterStatus(CharacterRepository()),
        ),
        ChangeNotifierProxyProvider<CharacterStatus, CharacterViewModel>(
          create: (_) => CharacterViewModel(
            tokenService: TokenService(),
            dioService: DioService(),
            status: CharacterStatus(CharacterRepository()), // 임시
          ),
          update: (_, characterStatus, previous) => CharacterViewModel(
            tokenService: TokenService(),
            dioService: DioService(),
            status: characterStatus,
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
      theme: AppTheme.lightTheme, // 🌞 기본 테마 (라이트)
      darkTheme: AppTheme.darkTheme, // 🌙 다크 테마 추가
      themeMode: ThemeMode.system, // 🔄 시스템 설정에 따라 자동 변경
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
