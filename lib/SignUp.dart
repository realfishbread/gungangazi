import 'package:flutter/material.dart';
import '../dto/user_dto.dart';
import '../repositories/user_repository.dart';
import '../services/TokenService.dart';  // TokenService 임포트
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> 
    with SingleTickerProviderStateMixin { // TickerProviderMixin 추가
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _realnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController; // 애니메이션 컨트롤러
  late Animation<Offset> _slideAnimation; // 슬라이드 애니메이션

  int _currentStep = 0;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;
  String _passwordFeedback = ''; // 비밀번호 유효성 검사 메시지
  bool _isPasswordValid = false; // 비밀번호 유효 여부
  bool _isPasswordVisible = false; // 비밀번호 표시 여부

  final List<String> steps = ['아이디', '이메일', '이름', '비밀번호', '성별'];
  final TokenService _tokenService = TokenService(); // 토큰 저장 서비스

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // 애니메이션 지속 시간
      vsync: this, // TickerProvider 사용
    );

    // 슬라이드 애니메이션 정의 (위에서 아래로)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // 화면 밖 위쪽에서 시작
      end: Offset.zero, // 화면 중앙으로 이동
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // 부드러운 움직임
    ));

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }

  bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 600; // 웹 기준 600px 이상
  }

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
  if (await _isFormValid()) {
    String? selectedGender = _isMaleSelected ? '남성' : '여성';

    final user = UserDTO(
      username: _nameController.text,
      email: _emailController.text,
      realname: _realnameController.text,
      password: _passwordController.text,
      gender: selectedGender,
    );

    try {
      final userRepository = UserRepository();
      final message = await userRepository.registerUser(user);

      if (message == "아이디가 이미 존재합니다.") {
        _showErrorDialog('아이디가 이미 존재합니다.');
      } else {
        _showErrorDialog('회원가입 성공');
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } catch (e) {
      _showErrorDialog('회원가입에 실패했습니다: $e');
    }
  }
}



  Future<bool> _isFormValid() async {
  // 이메일과 비밀번호 유효성 검사
  if (!_validateEmailAndPassword()) {
    return false; // 유효성 검사가 실패하면 false 반환
  }

  final email = _emailController.text;

  try {
    final userRepository = UserRepository();
    final response = await userRepository.sendEmailVerification(email);

    if (response == "이메일 인증 요청 발송됨") {
      _showErrorDialog('이메일 인증 링크를 발송했습니다. 메일을 확인해 주세요.');
      return true; // 이메일 인증 요청 성공
    } else {
      _showErrorDialog('이메일 인증 발송에 실패했습니다: $response');
      return false;
    }
  } catch (e) {
    _showErrorDialog('이메일 인증 발송 중 오류가 발생했습니다: $e');
    return false;
  }
}



void _validatePassword(String password) {
  final passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  if (password.isEmpty) {
    setState(() {
      _passwordFeedback = '비밀번호를 입력해 주세요.';
      _isPasswordValid = false;
    });
  } else if (!passwordRegex.hasMatch(password)) {
    setState(() {
      _passwordFeedback =
          '비밀번호는 8자 이상, 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다.';
      _isPasswordValid = false;
    });
  } else {
    setState(() {
      _passwordFeedback = '사용 가능한 비밀번호입니다.';
      _isPasswordValid = true;
    });
  }
}

  // 오류 다이얼로그 표시 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
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

  bool _validateEmailAndPassword() {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    _showErrorDialog('이메일과 비밀번호를 입력해 주세요.');
    return false; // 유효성 검사 실패
  }

  if (!emailRegex.hasMatch(_emailController.text)) {
    _showErrorDialog('올바른 이메일 주소를 입력해 주세요.');
    return false; // 이메일 형식이 올바르지 않음
  }

  if (!passwordRegex.hasMatch(_passwordController.text)) {
    _showErrorDialog('비밀번호는 8자 이상, 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다.');
    return false; // 비밀번호 형식이 올바르지 않음
  }

  return true; // 유효성 검사 성공
}

Widget _buildPasswordField() {
  return Container(
    width: 300, // 비밀번호 필드 너비 제한
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          obscureText: !_isPasswordVisible, // 상태에 따라 토글
          onChanged: _validatePassword,
          decoration: InputDecoration(
            labelText: '비밀번호',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off // 비밀번호 숨김 아이콘
                    : Icons.visibility, // 비밀번호 보임 아이콘
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible; // 상태 토글
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _passwordFeedback,
          style: TextStyle(
            fontSize: 12,
            color: _isPasswordValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildEmailFieldWithButton() {
  return Container(
    width: 300, // 전체 너비 제한
    child: Row(
      children: [
        Expanded(
          flex: 3, // 이메일 입력 필드
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '이메일',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8), // 입력 필드와 버튼 간격
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[100],
            foregroundColor: Colors.black,
          ),
          onPressed: () async {
            await _isFormValid(); // 이메일 인증 호출
          },
          child: const Text('인증'),
        ),
      ],
    ),
  );
}


Widget _buildStepForm() {
  return Column(
    children: [
      if (_currentStep == 0)_buildEmailFieldWithButton(),
      if (_currentStep == 1) _buildTextField(_realnameController, '이름'),
      if (_currentStep == 2)  _buildTextField(_nameController, '아이디'),
      if (_currentStep == 3) _buildPasswordField(), // 비밀번호 필드
      if (_currentStep == 4) _buildGenderSelection(),
      const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[100],
          foregroundColor: Colors.black,
        ),
        onPressed: _nextStep,
        child: Text(
          _currentStep == steps.length - 1 ? '회원가입' : '다음',
        ),
      ),
      const SizedBox(height: 16),
      Text('단계: ${steps[_currentStep]} (${_currentStep + 1}/${steps.length})'),
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('로그인 페이지로 돌아가기'),
      ),
    ],
  );
}


Widget _buildFullForm() {
  return Column(
    children: [
      _buildEmailFieldWithButton(), // 이메일 입력 필드 + 인증 버튼
      const SizedBox(height: 8),
      _buildTextField(_realnameController, '이름'),
      const SizedBox(height: 8),
      _buildTextField(_nameController, '아이디'),
      const SizedBox(height: 8),
      _buildPasswordField(), // 비밀번호 필드
      const SizedBox(height: 8),
      _buildGenderSelection(),
      const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[100],
          foregroundColor: Colors.black,
        ),
        onPressed: _completeSignUp,
        child: const Text('회원가입'),
      ),
    ],
  );
}


@override
Widget build(BuildContext context) {
  final bool isWebSize = isWeb(context); // 데스크톱 여부 확인

  return Scaffold(
    backgroundColor: const Color(0xFFFFFAEC), // 배경색
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
            children: [
              Text(
                'Gunganghazi?', // 건강아지 로고 텍스트
                style: TextStyle(
                  fontSize: 40, // 텍스트 크기 확대
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _slideAnimation, // 애니메이션 적용
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 600, // 최대 너비 설정
                    minHeight: isWebSize ? 500 : 300, // 데스크톱 모드에서 세로 길이 확대
                  ),
                  padding: const EdgeInsets.all(24.0), // 내부 여백 확대
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
                  // 이 부분을 가운데 정렬로 수정
                  child: Center( // **Container 내부에 Center 추가**
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 내용 크기에 맞춤
                      mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
                      crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
                      children: [
                        if (isWebSize)
                          _buildFullForm() // 모든 필드를 한 페이지에 표시
                        else
                          _buildStepForm(), // 단계별 표시
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: isWebSize // 데스크톱 상태에서만 표시
        ? Container(
            color: Colors.transparent, // 배경 투명
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '건강하지 | 고객 지원 문의 : +82 1234 5678 및 yoonh12288@gmail.com',
              style: TextStyle(
                fontSize: 11, // 텍스트 크기
                color: Colors.grey[700], // 회색 텍스트
              ),
              textAlign: TextAlign.center,
            ),
          )
        : null, // 모바일에서는 표시하지 않음
  );
}



  Widget _buildGenderSelection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center, // 부모 Column의 중앙 정렬
    children: [
      const Text(
        '성별',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center, // Row 내부 항목 중앙 정렬
        children: [
          Row(
            children: [
              Checkbox(
                value: _isMaleSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isMaleSelected = value ?? false;
                    _isFemaleSelected = !_isMaleSelected;
                  });
                },
              ),
              const Text('남성'),
            ],
          ),
          const SizedBox(width: 32), // 남성과 여성 사이 간격
          Row(
            children: [
              Checkbox(
                value: _isFemaleSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isFemaleSelected = value ?? false;
                    _isMaleSelected = !_isFemaleSelected;
                  });
                },
              ),
              const Text('여성'),
            ],
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
  String? hintText,
]) {
  return Container(
    width: 300, // 입력 필드 너비 제한 (픽셀 단위)
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
}
