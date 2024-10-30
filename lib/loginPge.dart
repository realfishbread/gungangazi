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

  Future<void> _login() async {
    // 서버로 로그인 요청 보내기
    LoginRequestDto loginRequest = LoginRequestDto(
      username: _nameController.text,
      password: _passwordController.text,
    );

    try {
      // 기본 아이디와 비밀번호로 검증 (예시)
      if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _loginFailed = true; // 입력 필드가 비어있으면 실패 처리
        });
        return;
      }
      
      LoginResponseDto? loginResponse = await _authRepository.login(loginRequest);

      if (loginResponse != null) {
        setState(() {
          _loginFailed = false;
        });
        // 로그인 성공 후 토큰 저장 로직 추가
        // 예: _tokenService.saveToken(loginResponse.token);
        Navigator.pushReplacementNamed(context, '/homeApp');
      } else {
        setState(() {
          _loginFailed = true; // 로그인 실패 처리
        });
        _showErrorDialog('로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.');
      }
    } catch (e) {
      print('로그인 중 에러 발생: $e');  // 에러 로그 출력
      _showErrorDialog('로그인 중 오류가 발생했습니다.'); // 실패 알림창 표시
    }
  }

  // 알림창 표시 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그인 오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 알림창 닫기
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

