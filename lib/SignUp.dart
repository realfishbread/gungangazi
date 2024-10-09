import 'package:flutter/material.dart';
import '../dto/user_dto.dart';
import '../repositories/user_repository.dart';

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
  final UserRepository _userRepository = UserRepository();

  void _nextStep() {
    setState(() {
      if (_currentStep < steps.length - 1) {
        _currentStep++;
      } else {
        _completeSignUp();
      }
    });
  }

  void _completeSignUp() async {
    String? selectedGender;
    if (_isMaleSelected) {
      selectedGender = '남성';
    } else if (_isFemaleSelected) {
      selectedGender = '여성';
    }

    // DTO 객체 생성
    final user = UserDTO(
      name: _nameController.text,
      email: _emailController.text,
      id: _idController.text,
      password: _passwordController.text,
      gender: selectedGender ?? '',
    );

    // 리포지토리를 사용하여 서버에 회원가입 요청
    await _userRepository.registerUser(user);

    // 회원가입 완료 후 로그인 페이지로 돌아가기
    Navigator.pop(context);
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
                          Navigator.pop(context);
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
                    _isFemaleSelected = !(_isMaleSelected);
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
                    _isMaleSelected = !(_isFemaleSelected);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

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
