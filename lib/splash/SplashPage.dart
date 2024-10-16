import 'package:gungangazi/mobile_home_page.dart';

import '../loginPge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 로그인 상태 확인을 위한 패키지 import
import '../main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // FlutterSecureStorage 인스턴스 생성
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // 애니메이션과 함께 일정 시간 후 로그인 상태 확인
    Future.delayed(const Duration(seconds: 3), () async {
      String? token = await storage.read(key: 'authToken');
      if (token != null) {
        // 토큰이 있으면 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MobileHomePage()), // 로그인 상태일 경우 홈 화면으로 이동
        );
      } else {
        // 토큰이 없으면 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Icon(Icons.local_hospital_outlined, size: 100, color: Colors.yellow[200]), // 로고
        ),
      ),
    );
  }
}
