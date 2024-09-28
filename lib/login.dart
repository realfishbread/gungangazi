import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  await KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_APP_KEY'); // 카카오 SDK 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login and Sign Up',
      theme: ThemeData(
        primarySwatch: Colors.yellow, // 사용자가 원하는 앱 색상
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _loginError; // 로그인 오류 메시지

  Future<void> _googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      setState(() {
        _loginError = '구글 로그인에 실패하였습니다.';
      });
    }
  }

  Future<void> _kakaoSignIn() async {
    try {
      final token = await AuthApi.instance.loginWithKakaoTalk();

      final credential = GoogleAuthProvider.credential(
        accessToken: token.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() {
        _loginError = '카카오 로그인에 실패하였습니다.';
      });
    }
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 로그인 성공 시 홈 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() {
        _loginError = '로그인에 실패하였습니다. 이메일 또는 비밀번호를 확인하세요.'; // 오류 메시지 설정
      });
    }
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4, // 그림자 효과
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 둥근 모서리
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '로그인',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: '아이디 (Email)'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  SizedBox(height: 8),
                  // 로그인 오류 메시지 표시
                  if (_loginError != null)
                    Text(
                      _loginError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('로그인'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _googleSignIn, // 구글 로그인 버튼
                    child: Text('구글로 로그인'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _kakaoSignIn, // 카카오 로그인 버튼
                    child: Text('카카오로 로그인'),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: _goToSignUp,
                    child: Text('계정이 없으신가요? 회원가입'),
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _selectedGender = 'Male'; // 기본 성별

  void _signUp() {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String email = _emailController.text;
    String name = _nameController.text;

    // 회원가입 성공 메시지 표시
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('환영합니다!'),
          content: Text('회원가입이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 메시지 창 닫기
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 화면으로 이동
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedGender,
              items: <String>['Male', 'Female']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
