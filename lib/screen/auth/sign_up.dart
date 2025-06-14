import 'package:flutter/material.dart';
import '../../dto/auth/user_dto.dart';
import '../../repositories/auth/user_repository.dart';
import '../../widget/alert.dart';
import '../../widget/is_web.dart';
import 'package:flutter/material.dart';
import 'sign_up_utils/animation_helper.dart'; // 애니메이션 파일 import

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
  final TextEditingController _verificationCodeController = TextEditingController(); // 인증 코드 입력 컨트롤러




  int _currentStep = 0;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  String _passwordFeedback = ''; // 비밀번호 유효성 검사 메시지
  String _confirmPasswordFeedback = ''; // 비밀번호 확인 메시지
  bool _isPasswordMatching = false; // 비밀번호 일치 여부
  bool _isPasswordValid = false; // 비밀번호 유효 여부
  bool _isPasswordVisible = false; // 비밀번호 표시 여부
  bool _isVerificationFieldVisible = false; // 인증 코드 입력 필드 표시 여부

  late SlideAnimationHelper _slideAnimationHelper;
  int ver =0;

  final List<String> steps = ['아이디', '이메일', '이름', '비밀번호', '성별'];

  @override
  void initState() {
    super.initState();
   _slideAnimationHelper = SlideAnimationHelper(vsync: this);
    _slideAnimationHelper.start();
  }

  @override
  void dispose() {
    _slideAnimationHelper.dispose();
    super.dispose();
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

   // 비밀번호 확인 입력 처리
  void _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordFeedback = '비밀번호 확인을 입력해 주세요.';
        _isPasswordMatching = false;
      });
    } else if (confirmPassword != _passwordController.text) {
      setState(() {
        _confirmPasswordFeedback = '비밀번호가 일치하지 않습니다.';
        _isPasswordMatching = false;
      });
    } else {
      setState(() {
        _confirmPasswordFeedback = '비밀번호가 일치합니다.';
        _isPasswordMatching = true;
      });
    }
  }

  // 회원가입 완료 함수
void _completeSignUp() async {
  // 비밀번호 유효성 검사
  if (!_isPasswordValid) {
    showErrorDialog(context,'비밀번호가 유효하지 않습니다. 다시 확인해 주세요.');
    return;
  }
  if (ver == 0) {
    showErrorDialog(context,'이메일 인증을 완료해 주세요.');
    return;
  }
  if (!_isMaleSelected && !_isFemaleSelected) {
    showErrorDialog(context,'성별을 선택해 주세요.');
    return;
  }

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

    // 서버 응답 처리
    if (message == "아이디가 이미 존재합니다.") {
      showErrorDialog(context,'아이디가 이미 존재합니다.');
    } else if (message == "회원가입 성공") {
      showSuccessDialog(context,'회원가입 성공');
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      showErrorDialog(context,'회원가입에 실패했습니다.');
    }
  } catch (e) {
    showErrorDialog(context,'회원가입에 실패했습니다: $e');
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
      showSuccessDialog(context, '이메일 인증 링크를 발송했습니다. 메일을 확인해 주세요.');
      return true; // 이메일 인증 요청 성공
    } else {
      showErrorDialog(context, response);
      return false;
    }
  } catch (e) {
    showErrorDialog(context, '이메일 인증 발송 중 오류가 발생했습니다: $e');
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
   // 비밀번호 유효성 검사 후 비밀번호 확인도 다시 검사

}

  

  bool _validateEmailAndPassword() {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  if (_emailController.text.isEmpty ) {
    showErrorDialog(context,'이메일을 입력해 주세요.');
    return false; // 유효성 검사 실패
  }
  

  if (!emailRegex.hasMatch(_emailController.text)) {
    showErrorDialog(context,'올바른 이메일 주소를 입력해 주세요.');
    return false; // 이메일 형식이 올바르지 않음
  }

  

  return true; // 유효성 검사 성공
}







void _verifyCode() async {
  final email = _emailController.text;
  final token = _verificationCodeController.text;

  if (token.isEmpty) {
    showErrorDialog(context,'인증 코드를 입력해 주세요.');
    return;
  }

  final userRepository = UserRepository();
  try {
    // 디버깅 로그 추가
    print('이메일: $email, 인증 코드: $token');

    final result = await userRepository.verifyEmailCode(email, token);

    if (result == '이메일 인증이 완료되었습니다.') {
      ver =1;
      showSuccessDialog(context,'인증 성공!');
      setState(() {
        _isVerificationFieldVisible = false; // 인증 필드 숨기기
        _nextStep(); // 다음 단계로 이동
      });
    } else {
      showErrorDialog(context,result); // 오류 메시지 표시
    }
  } catch (e) {
    showErrorDialog(context,'서버 요청 중 오류가 발생했습니다: $e');
  }
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

Widget _buildPasswordField() {
  return SizedBox(
    width: 300, // 비밀번호 필드 너비 제한
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          // !를 사용해 _isPasswordVisible이 false일 때 obscureText를 true로 만듦
          obscureText: !_isPasswordVisible,
          // 추가: obscureText가 true일 때 표시될 마스킹 문자
          obscuringCharacter: '●',

          onChanged: _validatePassword,
          decoration: InputDecoration(
            labelText: '비밀번호',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off // 비밀번호 숨김 아이콘
                    : Icons.visibility,     // 비밀번호 보임 아이콘
              ),
              onPressed: () {
                setState(() {
                  // 아이콘 누를 때마다 true <-> false 토글
                  _isPasswordVisible = !_isPasswordVisible;
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
  return SizedBox(
    width: 300, // 전체 너비 제한
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
      children: [
        Row(
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
                 _validateEmailAndPassword();
                await _isFormValid(); // 이메일 인증 호출
                setState(() {
                  _isVerificationFieldVisible = true; // 인증 코드 입력칸 표시
                });
              },
              child: const Text('인증'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isVerificationFieldVisible) // 인증 코드 입력칸 표시 조건
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _verificationCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '인증 코드 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  _verifyCode(); // 인증 코드 검증 함수 호출
                },
                child: const Text('확인'),
              ),
            ],
          ),

      ],
    ),
  );
}





Widget _buildFullForm() {
  return Column(
    children: [
      _buildEmailFieldWithButton(), // 이메일 입력 필드 + 인증 버튼
      const SizedBox(height: 10),
      _buildTextField(_realnameController, '이름'),
      const SizedBox(height: 10),
      _buildTextField(_nameController, '아이디'),
      const SizedBox(height: 10),
      _buildPasswordField(), // 비밀번호 필드
      const SizedBox(height: 10),
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
  final bool isWebSize = isWeb(context); // 웹 기준 여부 확인

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
                  Image.asset(
                    'assets/signin.png',
                    width: 300,
                    height: 100,
                  ),
              const SizedBox(height: 4),
              // 애니메이션 비활성화 및 Container 크기 조정
              isWebSize
                  ? SlideTransition(
                      position: _slideAnimationHelper.slideAnimation,
                      child: _buildContainer(isWebSize),
                    )
                  : _buildContainer(isWebSize), // 모바일에서는 애니메이션 없이 바로 표시
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: isWebSize
        ? Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '건강하지 | 고객 지원 문의 : +82 1234 5678 및 yoonh12288@gmail.com',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          )
        : null, // 모바일에서는 하단바 제거
  );
}

// Container 크기 조정 함수
Widget _buildContainer(bool isWebSize) {
  return Container(
    constraints: BoxConstraints(
      maxWidth: isWebSize ? 500 : 400, // 모바일 화면에서는 너비 작게
      minHeight: isWebSize ? 500 : 200, // 모바일 화면에서는 높이 작게
    ),
    padding: const EdgeInsets.all(16.0), // 내부 여백
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
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isWebSize)
            _buildFullForm() // 모든 필드를 한 페이지에 표시
          else
            _buildStepForm(), // 단계별 표시
        ],
      ),
    ),
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
    return SizedBox(
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
