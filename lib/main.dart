import 'package:flutter/foundation.dart';
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

  final Widget entryPage = kIsWeb
      ? const WebHomePage()
      : const MobileHomePage(); // ❗ context 없이 플랫폼으로 먼저 분기

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          //바뀐 거 있으면 알리겠습니다.
          create: (_) => CharacterStatus(CharacterRepository()),
        ),
        ChangeNotifierProxyProvider<CharacterStatus, CharacterViewModel>(
            create: (context) {
          final status = Provider.of<CharacterStatus>(context, listen: false);
          return CharacterViewModel(
            tokenService: TokenService(),
            dioService: DioService(),
            status: status,
          );
        }, update: (context, characterStatus, previous) {
          previous?.updateStatus(characterStatus);
          return previous!;
        }),
      ],
      child: MyApp(entryPage: entryPage),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget entryPage;
  const MyApp({super.key, required this.entryPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강하지',
      theme: AppTheme.lightTheme, // 🌞 기본 테마 (라이트)
      darkTheme: AppTheme.darkTheme, // 🌙 다크 테마 추가
      themeMode: ThemeMode.system, // 🔄 시스템 설정에 따라 자동 변경
      home: entryPage, // ✅ context가 필요 없는 시점에서 분기 완료
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
