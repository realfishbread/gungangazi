import 'package:flutter/material.dart';

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

  // 현재 보여줄 단계
  int _currentStep = 0;

  // 각 단계별 필드로 구성된 리스트
  final List<String> steps = ['이름', '이메일', '아이디', '비밀번호'];

  // 단계별로 입력받은 값을 검증하고 다음 단계로 이동
  void _nextStep() {
    setState(() {
      if (_currentStep < steps.length - 1) {
        _currentStep++;
      } else {
        // 모든 단계 완료 후 회원가입 처리
        _completeSignUp();
      }
    });
  }

  // 회원가입 완료 처리 함수
  void _completeSignUp() {
    print('회원가입 완료');
    print('이름: ${_nameController.text}');
    print('이메일: ${_emailController.text}');
    print('아이디: ${_idController.text}');
    print('비밀번호: ${_passwordController.text}');

    // 회원가입 완료 후 로그인 페이지로 돌아가기
    Navigator.pop(context);
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
                        ),
                      if (_currentStep == 1)
                        _buildTextField(
                          controller: _emailController,
                          labelText: '이메일',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      if (_currentStep == 2)
                        _buildTextField(
                          controller: _idController,
                          labelText: '아이디',
                        ),
                      if (_currentStep == 3)
                        _buildTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          obscureText: true,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

