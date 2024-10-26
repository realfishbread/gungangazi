import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart'; // MySQL 패키지
import '../dto/user_dto.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_dao.dart'; // UserDAO 임포트

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
  late final UserDAO _userDAO; // UserDAO 선언

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // MySQL 연결 초기화 함수 호출
  }

  // MySQL 연결 초기화 함수
  Future<void> _initializeDatabase() async {
    final connectionSettings = ConnectionSettings(
      host: 'database-1.c76iaa8ycok0.ap-northeast-2.rds.amazonaws.com',  // 실제 호스트 정보로 변경
      port: 3306,         // MySQL 포트
      user: 'gungangazi', // 사용자명
      password: 'endbackend!', // 비밀번호
      db: 'appdb', // 데이터베이스 이름
    );
    
    final mySqlConnection = await MySqlConnection.connect(connectionSettings);

    // UserDAO 인스턴스 생성
    _userDAO = UserDAO(mySqlConnection);
  }

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
    // 유효성 검사
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _idController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (!_isMaleSelected && !_isFemaleSelected)) {
      // 경고 메시지 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('입력 오류'),
          content: const Text('모든 필드를 입력해 주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    String? selectedGender;
    if (_isMaleSelected) {
      selectedGender = '남성';
    } else if (_isFemaleSelected) {
      selectedGender = '여성';
    }

    // DTO 객체 생성
    final user = UserDTO(
      username: _nameController.text,
      email: _emailController.text,
      id: _idController.text,
      password: _passwordController.text,
      gender: selectedGender ?? '',
    );

    try {
      // 서버에 회원가입 요청
      await _userRepository.registerUser(user);

      // 데이터베이스에 사용자 저장
      await _userDAO.saveUser(user);

      // 회원가입 성공 시 로그인 페이지로 이동
      Navigator.pop(context);
    } catch (e) {
      // 오류 처리 (예: 다이얼로그 표시)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('회원가입 실패'),
          content: Text('회원가입에 실패했습니다: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
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
