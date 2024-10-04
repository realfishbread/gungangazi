import 'SignUp.dart'; // 회원가입 페이지를 불러오기 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 로그인 시 아이디와 비밀번호 입력을 관리할 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 로그인 실패 여부를 나타내는 변수
  bool _loginFailed = false;

  // 테스트용 유효한 아이디와 비밀번호
  final String validMemberId = 'testUser';
  final String validPassword = 'password123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // 앱바 숨기기
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로그인 페이지 중앙에 아이콘 표시
                Icon(
                  Icons.local_hospital_outlined,
                  size: 100,
                  color: Colors.yellow[400], // 아이콘 색상 설정
                ),
                const SizedBox(height: 24),

                // 로그인 박스
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400, // 최대 너비 400px로 설정
                  ),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // 박스 배경색
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // 그림자 색상
                        blurRadius: 10, // 그림자 퍼짐 정도
                        offset: const Offset(0, 4), // 그림자의 위치
                      ),
                    ],
                  ),
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
                      const SizedBox(height: 16),

                      // 로그인 실패 시 메시지 표시
                      if (_loginFailed)
                        const Text(
                          '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                          style: TextStyle(color: Colors.red),
                        ),

                      // 로그인 버튼
                      ElevatedButton(
                        onPressed: () {
                          String memberId = _idController.text;
                          String password = _passwordController.text;

                          setState(() {
                            // 아이디와 비밀번호가 유효한 경우
                            if (memberId == validMemberId && password == validPassword) {
                              _loginFailed = false; // 로그인 성공
                              Navigator.pushReplacementNamed(
                                context,
                                kIsWeb ? '/homeWeb' : '/homeApp', // 웹과 앱에 따라 홈 경로 설정
                              );
                            } else {
                              _loginFailed = true; // 로그인 실패
                            }
                          });
                        },
                        child: const Text('로그인'),
                      ),
                      const SizedBox(height: 16),

                      // 회원가입 페이지로 이동하는 버튼
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text('회원가입'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
