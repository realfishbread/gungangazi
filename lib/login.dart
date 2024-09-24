import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login and Sign Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

// 로그인 페이지
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 가짜 데이터베이스 역할 (아이디와 비밀번호 저장)
  final String validMemberId = 'testUser';
  final String validPassword = 'password123';

  bool _loginFailed = false; // 로그인 실패 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 아이디 입력 필드
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 비밀번호 입력 필드
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // 비밀번호 숨기기
            ),
            SizedBox(height: 8),
            // 로그인 실패 메시지 표시
            if (_loginFailed) // 로그인 실패 시만 메시지 표시
              Text(
                '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                String memberId = _idController.text;
                String password = _passwordController.text;

                // 로그인 검증 로직 (아이디와 비밀번호가 올바른지 확인)
                setState(() {
                  if (memberId == validMemberId && password == validPassword) {
                    _loginFailed = false; // 로그인 성공 시 실패 메시지 숨기기
                    // 로그인 성공 후 프로필 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(memberId: memberId)),
                    );
                  } else {
                    _loginFailed = true; // 로그인 실패 시 메시지 표시
                  }
                });
              },
              child: Text('로그인'),
            ),
            SizedBox(height: 16),
            // 회원가입으로 이동하는 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

// 프로필 페이지 (로그인 후 이동)
class ProfilePage extends StatelessWidget {
  final String memberId;

  ProfilePage({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 페이지'),
      ),
      body: Center(
        child: Text('환영합니다, $memberId님'),
      ),
    );
  }
}

// 회원가입 페이지
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedGender = '남성'; // 기본값: 남성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 아이디 입력 필드
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 이름 입력 필드
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 이메일 입력 필드
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 비밀번호 입력 필드
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // 비밀번호 가리기
            ),
            SizedBox(height: 16),
            // 성별 선택 라디오 버튼
            Row(
              children: [
                Text('성별: '),
                Expanded(
                  child: ListTile(
                    title: const Text('남성'),
                    leading: Radio<String>(
                      value: '남성',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('여성'),
                    leading: Radio<String>(
                      value: '여성',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 회원가입 버튼
            ElevatedButton(
              onPressed: () {
                String memberId = _idController.text;
                String name = _nameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;

                // 회원가입 로직 추가 가능
                print('아이디: $memberId');
                print('이름: $name');
                print('이메일: $email');
                print('비밀번호: $password');
                print('성별: $_selectedGender');

                // 가입 축하 메시지 다이얼로그 호출
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('가입 완료'),
                      content: Text('가입을 축하합니다!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // 다이얼로그 닫기
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text('확인'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

