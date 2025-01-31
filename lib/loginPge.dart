import 'SignUp.dart'; // 회원가입 페이지를 불러오기 위해 추가
import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart'; // AuthRepository import
import '../../dto/login_dto.dart'; // Login DTO import
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

final _googleSignIn = GoogleSignIn(
  clientId: '423735826070-9dq9dd52a4t5u66krjlg2nm0cpq8f92o.apps.googleusercontent.com',
  scopes: <String>[
    'openid', 'email', 'profile'
  ],
);


class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final Dio _dio = Dio(); // Dio 인스턴스 추가
  bool _loginFailed = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

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

    Future<void> _sendTokenToServer(String? idToken, String? accessToken) async {
  try {
    final response = await _dio.post(
      'https://gungangazi.site/api/auth/google-login',
      data: {'idToken': idToken, 'accessToken': accessToken},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200) {
      final responseBody = response.data;
      print('서버 응답: $responseBody');

      // JWT 토큰 저장
      final String token = responseBody['token'];
      await _saveToken(token);

      // 기존 사용자 여부 확인
      final bool existingUser = responseBody['existingUser'] ?? false;

      // 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/homeApp');

      // 필요 시 팝업 표시
      if (existingUser) {
        _showInfoDialog('기존 회원으로 로그인되었습니다.');
      } else {
        _showInfoDialog('신규 회원으로 가입되었습니다.');
      }
    } else {
      _showErrorDialog('Google 로그인 실패: 서버 오류 (${response.statusCode})');
    }
  } catch (e) {
    print('서버 요청 중 오류 발생: $e');
    _showErrorDialog('서버 요청 중 오류가 발생했습니다.');
  }
}
Future<void> _googleLogin() async {
  try {
    // Google 계정 로그인
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print('Google 로그인 취소됨');
      return;
    }

    // ID 토큰 및 Access Token 가져오기
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    if (idToken != null || accessToken != null) {
      print('Google ID Token: $idToken');
      print('Google Access Token: $accessToken');

      // 서버로 토큰 전송
      await _sendTokenToServer(idToken, accessToken);
    } else {
      _showErrorDialog('Google 인증 정보가 부족합니다.');
    }
  } catch (e) {
    print('Google 로그인 중 오류 발생: $e');
    _showErrorDialog('Google 로그인 중 오류가 발생했습니다.');
  }
}




  // JWT 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token);
    print('JWT 토큰 저장 완료: $token');
  }

  // 정보 팝업 표시
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

  

void _showConfirmDialog({
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 닫기
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 닫기
              onConfirm(); // 확인 버튼 눌렀을 때 실행할 작업
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
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus(); // 다음 필드로 포커스를 이동
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          obscuringCharacter: '●',
                          // 엔터 버튼의 동작 설정
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            _login(); // 엔터를 누르면 로그인 시도
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
                            backgroundColor: Colors.yellow[100], // 버튼 배경색을 검정으로 설정
                            foregroundColor: Colors.black, // 텍스트 색상을 흰색으로 설정
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
                          onPressed: () {
                            // 카카오 로그인 로직
                          },
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
                          onPressed: _isLoading
                              ? null // 로딩 중일 때 버튼 비활성화
                              : () async {
                                  setState(() {
                                    _isLoading = true; // 로딩 시작
                                  });
                                  try {
                                    await _googleLogin(); // Google 로그인 실행
                                  } finally {
                                    setState(() {
                                      _isLoading = false; // 로딩 종료
                                    });
                                  }
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