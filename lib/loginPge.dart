import 'SignUp.dart'; // 회원가입 페이지를 불러오기 위해 추가
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK import
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

      if (_nameController.text == 'testUser' && _passwordController.text == 'password123') {
        print('로컬 로그인 성공, 가짜 유저 로그인');
        setState(() {
          _loginFailed = false;
        });
        Navigator.pushReplacementNamed(context, '/homeApp');
        return;
      }

      LoginResponseDto? loginResponse = await _authRepository.login(loginRequest);

      if (loginResponse != null) {
        String token = loginResponse.token;
        print('로그인 성공, 토큰: $token');
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

  Future<void> _loginWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('카카오 로그인 성공: ${token.accessToken}');
      Navigator.pushReplacementNamed(context, '/homeApp');
    } catch (e) {
      print('카카오 로그인 실패: $e');
      _showErrorDialog('카카오 로그인 중 오류가 발생했습니다.');
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
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/splash/splash_image.png',
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
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          obscuringCharacter: '●',
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            _login();
                          },
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
                        ),
                        const SizedBox(height: 16),
                        if (_loginFailed)
                          const Text(
                            '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[100],
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _login,
                          child: const Text('로그인'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '회원이 아니신가요?',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
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
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'SNS로 로그인하기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: Image.asset(
                            'assets/icons/kakao_icon.png',
                            width: 30,
                            height: 30,
                          ),
                          label: const Text('카카오로 로그인'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFEE500),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _loginWithKakao,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: Image.asset(
                            'assets/icons/google_icon.png',
                            width: 22,
                            height: 22,
                          ),
                          label: const Text('구글로 로그인'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: () {
                            // 구글 로그인 로직
                          },
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
