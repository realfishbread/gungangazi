import 'package:flutter/material.dart';
import '../dto/user_dto.dart';
import '../repositories/user_repository.dart';
import '../services/TokenService.dart';  // TokenService 임포트

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _currentStep = 0;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  final List<String> steps = ['이름', '이메일', '아이디', '비밀번호', '성별'];
  final TokenService _tokenService = TokenService();  // 토큰 저장 서비스

  // 다음 단계 버튼 처리
  void _nextStep() {
    setState(() {
      if (_currentStep < steps.length - 1) {
        _currentStep++;
      } else {
        _completeSignUp();  // 회원가입 완료 후 토큰 저장
      }
    });
  }

  // 회원가입 완료 함수
  void _completeSignUp() async {
    if (_isFormValid()) {
      // 성별 설정
      String? selectedGender = _isMaleSelected ? '남성' : '여성';

      // DTO 객체 생성
      final user = UserDTO(
        username: _nameController.text,
        email: _emailController.text,
        id: _idController.text,
        password: _passwordController.text,
      );

      try {
        // 서버에 회원가입 요청
        final userRepository = UserRepository();
        final token = await userRepository.registerUser(user);  // 서버에서 받은 토큰

        if (token != null) {
          // 토큰 저장
          await _tokenService.saveToken(token);
          print('회원가입 성공, 받은 토큰: $token');

          // 회원가입 성공 시 로그인 페이지로 이동
          Navigator.pop(context);
        } else {
          _showErrorDialog('회원가입 실패: 토큰을 받지 못했습니다.');
        }
      } catch (e) {
        _showErrorDialog('회원가입에 실패했습니다: $e');
      }
    }
  }

  // 유효성 검사 함수
  bool _isFormValid() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _idController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (!_isMaleSelected && !_isFemaleSelected)) {
      _showErrorDialog('모든 필드를 입력해 주세요.');
      return false;
    }
    return true;
  }

  // 오류 다이얼로그 표시 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입력 오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
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
                      if (_currentStep == 0)
                        _buildTextField(_nameController, '이름'),
                      if (_currentStep == 1)
                        _buildTextField(_emailController, '이메일', TextInputType.emailAddress),
                      if (_currentStep == 2)
                        _buildTextField(_idController, '아이디'),
                      if (_currentStep == 3)
                        _buildTextField(_passwordController, '비밀번호', TextInputType.text, true),
                      if (_currentStep == 4)
                        _buildGenderSelection(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(
                          _currentStep == steps.length - 1 ? '회원가입' : '다음',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('단계: ${steps[_currentStep]} (${_currentStep + 1}/${steps.length})'),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);  // 로그인 페이지로 돌아가기
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

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('남성'),
                value: _isMaleSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isMaleSelected = value ?? false;
                    _isFemaleSelected = !_isMaleSelected;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('여성'),
                value: _isFemaleSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isFemaleSelected = value ?? false;
                    _isMaleSelected = !_isFemaleSelected;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, [
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  ]) {
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
