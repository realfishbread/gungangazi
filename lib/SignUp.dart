import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 회원가입 시 필요한 필드 입력을 관리할 컨트롤러들
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 각 필드에 대한 유효성 검사 상태
  bool _nameValid = true;
  bool _emailValid = true;
  bool _idValid = true;
  bool _passwordValid = true;

  // 현재 보여줄 단계
  int _currentStep = 0;

  // 각 단계별 필드로 구성된 리스트
  final List<String> steps = ['이름', '이메일', '아이디', '비밀번호'];

  // 단계별로 입력받은 값을 검증하고 다음 단계로 이동
  void _nextStep() {
    setState(() {
      // 각 단계에 따라 빈 필드 체크
      if (_currentStep == 0 && _nameController.text.isEmpty) {
        _nameValid = false;
      } else if (_currentStep == 1 && _emailController.text.isEmpty) {
        _emailValid = false;
      } else if (_currentStep == 2 && _idController.text.isEmpty) {
        _idValid = false;
      } else if (_currentStep == 3 && _passwordController.text.isEmpty) {
        _passwordValid = false;
      } else {
        // 모든 단계가 유효하면 다음 단계로 이동
        if (_currentStep < steps.length - 1) {
          _currentStep++;
        } else {
          // 모든 단계 완료 후 회원가입 처리
          _completeSignUp();
        }
      }
    });
  }

  // 회원가입 완료 처리 함수 (데이터 서버 전송)
  Future<void> _completeSignUp() async {
    // 사용자 입력 정보를 JSON 형식으로 구성
    final Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'username': _idController.text,
      'password': _passwordController.text,
    };

    // 서버로 데이터 전송
    final response = await http.post(
      Uri.parse('http://15.164.140.55/api/signup'), // 서버 URL을 설정
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      // 회원가입 성공 시
      print('회원가입 성공');
      Navigator.pop(context); // 로그인 페이지로 돌아가기
    } else {
      // 회원가입 실패 시
      print('회원가입 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // 로그인 페이지와 마찬가지로 앱바 숨기기
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

                // 회원가입 박스 디자인 (로그인과 동일하게)
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400, // 최대 너비를 400px로 설정
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
                      // 현재 단계에 따라 다른 입력 필드 표시
                      if (_currentStep == 0)
                        _buildTextField(
                          controller: _nameController,
                          labelText: '이름',
                          isValid: _nameValid,
                        ),
                      if (_currentStep == 1)
                        _buildTextField(
                          controller: _emailController,
                          labelText: '이메일',
                          keyboardType: TextInputType.emailAddress,
                          isValid: _emailValid,
                        ),
                      if (_currentStep == 2)
                        _buildTextField(
                          controller: _idController,
                          labelText: '아이디',
                          isValid: _idValid,
                        ),
                      if (_currentStep == 3)
                        _buildTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          obscureText: true,
                          isValid: _passwordValid,
                        ),
                      const SizedBox(height: 16),

                      // 다음 버튼 (회원가입 마지막 단계에서는 '회원가입'으로 표시)
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(
                          _currentStep == steps.length - 1 ? '회원가입' : '다음',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 현재 단계를 표시 (이름, 이메일, 아이디, 비밀번호 순서)
                      Text('단계: ${steps[_currentStep]} (${_currentStep + 1}/${steps.length})'),

                      // 로그인 페이지로 돌아가는 버튼
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 로그인 페이지로 돌아가기
                        },
                        child: const Text('로그인 페이지로 돌아가기'),
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

  // 공통된 입력 필드를 생성하는 함수
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isValid = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            errorText: isValid ? null : '정보를 적지 않았습니다', // 필드가 유효하지 않으면 오류 메시지 표시
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
