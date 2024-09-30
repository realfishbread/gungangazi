import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _loginFailed = false; // 로그인 실패 여부
  bool _isSignUpMode = false; // 회원가입 모드 여부

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
                // 중앙의 아이콘 추가
                Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.yellow[400], // 아이콘 색상 설정
                ),
                const SizedBox(height: 24),

                // 로그인/회원가입 박스 중앙에 배치
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400, // 최대 너비를 400px로 설정 (일반적인 로그인 박스 크기)
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
                      if (_isSignUpMode)
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '이름',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      if (_isSignUpMode) const SizedBox(height: 16),

                      // 아이디 입력 필드
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: '아이디',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_isSignUpMode)
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      if (_isSignUpMode) const SizedBox(height: 16),

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

                      if (_loginFailed && !_isSignUpMode)
                        const Text(
                          '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                          style: TextStyle(color: Colors.red),
                        ),

                      ElevatedButton(
                        onPressed: () {
                          if (_isSignUpMode) {
                            // 회원가입 처리 로직
                            print('회원가입 완료');
                            print('아이디: ${_idController.text}');
                            print('이름: ${_nameController.text}');
                            print('이메일: ${_emailController.text}');
                            setState(() {
                              _isSignUpMode = false; // 회원가입 완료 후 로그인 모드로 돌아감
                            });
                          } else {
                            String memberId = _idController.text;
                            String password = _passwordController.text;

                            setState(() {
                              if (memberId == validMemberId && password == validPassword) {
                                _loginFailed = false; // 로그인 성공
                                Navigator.pushReplacementNamed(
                                  context,
                                  kIsWeb ? '/homeWeb' : '/homeApp', // 웹과 앱에 따라 홈 경로 다르게
                                );
                              } else {
                                _loginFailed = true; // 로그인 실패 시 메시지 표시
                              }
                            });
                          }
                        },
                        child: Text(_isSignUpMode ? '회원가입' : '로그인'),
                      ),
                      const SizedBox(height: 16),

                      // 로그인 모드/회원가입 모드 전환 버튼
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = !_isSignUpMode;
                          });
                        },
                        child: Text(_isSignUpMode ? '로그인 페이지로 돌아가기' : '회원가입'),
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
