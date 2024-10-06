import 'SignUp.dart'; // 회원가입 페이지를 불러오기 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../repositories/auth_repository.dart'; // AuthRepository import
import '../../dto/login_dto.dart'; // Login DTO import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _loginFailed = false;

  // 기본 아이디와 비밀번호 (나중에 쉽게 제거 가능)
  final String _defaultUsername = "testUser";
  final String _defaultPassword = "password123";

  Future<void> _login() async {
    String username = _idController.text;
    String password = _passwordController.text;

    // 기본 아이디와 비밀번호로 검증
    if (username == _defaultUsername && password == _defaultPassword) {
      setState(() {
        _loginFailed = false;
      });
      Navigator.pushReplacementNamed(
        context,
        kIsWeb ? '/homeWeb' : '/homeApp',
      );
      return;
    }

    // 서버로 로그인 요청 보내기
    LoginRequestDto loginRequest = LoginRequestDto(
      username: username,
      password: password,
    );

    try {
      LoginResponseDto? loginResponse = await _authRepository.login(loginRequest);

      if (loginResponse != null) {
        // 로그인 성공 시 홈 화면으로 이동
        setState(() {
          _loginFailed = false;
        });
        Navigator.pushReplacementNamed(
          context,
          kIsWeb ? '/homeWeb' : '/homeApp',
        );
      } else {
        // 로그인 실패
        setState(() {
          _loginFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        _loginFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 100,
                  color: Colors.yellow[400],
                ),
                const SizedBox(height: 24),
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: '아이디',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: '비밀번호',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      if (_loginFailed)
                        const Text(
                          '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ElevatedButton(
                        onPressed: _login, // 로그인 함수 호출
                        child: const Text('로그인'),
                      ),
                      const SizedBox(height: 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
