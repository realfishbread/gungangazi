import 'SignUp.dart'; // 회원가입 페이지를 불러오기 위해 추가
import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart'; // AuthRepository import
import '../dto/login_dto.dart'; // Login DTO import
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../core_services/token_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '423735826070-9dq9dd52a4t5u66krjlg2nm0cpq8f92o.apps.googleusercontent.com',
  scopes: <String>[
    'openid',
    'email',
    'profile',
    'https://www.googleapis.com/auth/user.gender.read',
  ],
);

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final TokenService _tokenService =TokenService();
  final Dio _dio = Dio(BaseOptions(
  baseUrl: 'https://gungangazi.site',
  connectTimeout:  const Duration(seconds: 10),
  receiveTimeout:  const Duration(seconds: 10),
)); // Dio 인스턴스 추가
  bool _loginFailed = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _googleSignIn.signInSilently();
    }
  }

  

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
        print('로그인 성공: $token');
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

 

   /// **🔹 Google 로그인 버튼 누르면 호출**
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // 레포지토리 통해 구글 로그인
      final responseBody = await _authRepository.googleLogin();
      if (responseBody != null) {
        // 로그인 성공 시
        Navigator.pushReplacementNamed(context, '/homeApp', arguments: {
          'email': responseBody['email'],
          'realname': responseBody['realname'],
          'existingUser': responseBody['existingUser'],
          'gender': responseBody['gender'],
          'username': responseBody['username'],
          'token': responseBody['token'],
        });

        _showInfoDialog(
          responseBody['existingUser']
              ? '기존 회원으로 로그인되었습니다.'
              : '신규 회원으로 가입되었습니다.',
        );
      } else {
        _showErrorDialog('Google 로그인 실패');
      }
    } catch (e) {
      print('Google 로그인 중 오류 발생: $e');
      _showErrorDialog('Google 로그인 중 오류가 발생했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }


 

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token);
    print('JWT 토큰 저장 완료: $token');
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
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
                    'assets/logo.png',
                    width: 300,
                    height: 200,
                  ),
                  const SizedBox(height: 1),
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
                          onPressed: _isLoading ? null : _handleGoogleLogin, // ✅ 여기만 수정!
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
