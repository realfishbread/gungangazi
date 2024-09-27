import 'package:example4/main.dart';
import 'package:flutter/material.dart';

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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // 초기 경로 설정
      routes: {
        '/': (context) => const LoginPage(),  // 로그인 페이지
        '/home': (context) => const MyHomePage(),  // 메인 페이지로 이동할 경로 설정
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 가짜 데이터베이스 역할 (아이디와 비밀번호 저장)
  final String validMemberId = 'testUser';
  final String validPassword = 'password123';

  bool _loginFailed = false; // 로그인 실패 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 아이디 입력 필드
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 비밀번호 입력 필드
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // 비밀번호 숨기기
            ),
            const SizedBox(height: 8),
            // 로그인 실패 메시지 표시
            if (_loginFailed) // 로그인 실패 시만 메시지 표시
              const Text(
                '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                String memberId = _idController.text;
                String password = _passwordController.text;

                // 로그인 검증 로직 (아이디와 비밀번호가 올바른지 확인)
                setState(() {
                  if (memberId == validMemberId && password == validPassword) {
                    _loginFailed = false; // 로그인 성공 시 실패 메시지 숨기기
                    // 로그인 성공 후 메인 페이지로 이동
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    _loginFailed = true; // 로그인 실패 시 메시지 표시
                  }
                });
              },
              child: const Text('로그인'),
            ),
            const SizedBox(height: 16),
            // 회원가입으로 이동하는 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}



// 회원가입 페이지
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입 페이지'),
      ),
      body: const Center(
        child: Text('회원가입 페이지 내용'),
      ),
    );
  }
}
