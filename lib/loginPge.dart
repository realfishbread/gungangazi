import 'SignUp.dart'; // 회원가입 페이지를 불러오기 위해 추가
import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart'; // AuthRepository import
import '../../dto/login_dto.dart'; // Login DTO import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _loginFailed = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    // 서버로 로그인 요청 보내기
    LoginRequestDto loginRequest = LoginRequestDto(
      username: _nameController.text,
      password: _passwordController.text,
    );

    try {
      if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _loginFailed = true;
        });
        return;
      }

      // 로컬 테스트용 가짜 아이디와 비밀번호 체크
      if (_nameController.text == 'testUser' && _passwordController.text == 'password123') {
        print('로컬 로그인 성공, 가짜 유저 로그인');
        setState(() {
          _loginFailed = false;
        });
        Navigator.pushReplacementNamed(context, '/homeApp');
        return;
      }

      // 로그인 API 호출
      LoginResponseDto? loginResponse = await _authRepository.login(loginRequest);

      if (loginResponse != null) {
        String token = loginResponse.token;
        String message = loginResponse.message;
        print('로그인 성공, 메시지: $message, 토큰: $token');
        setState(() {
          _loginFailed = false;
        });
        Navigator.pushReplacementNamed(context, '/homeApp');
      } else {
        setState(() {
          _loginFailed = true;
        });
        _showErrorDialog('로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.');
      }
    } catch (e) {
      print('로그인 중 에러 발생: $e');
      _showErrorDialog('로그인 중 오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그인'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFAEC),
        ), // 배경색을 파스텔 옐로우로 설정
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/splash/splash_image.png', // 로고 아이콘을 이미지로 변경
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '아이디',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                        ),
                        const SizedBox(height: 16),
                        if (_loginFailed)
                          const Text(
                            '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[100], // 버튼 배경색을 검정으로 설정
                            foregroundColor: Colors.black, // 텍스트 색상을 흰색으로 설정
                          ),
                          onPressed: _login,
                          child: const Text('로그인'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, // 텍스트 색상을 검정으로 설정
                          ),
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
      ),
    );
  }
}
