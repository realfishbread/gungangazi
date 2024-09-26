import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      theme: ThemeData(
        primaryColor: Colors.yellow,
      ),
    );
  }
}

// 로그인 페이지
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인', style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 로그인 시 프로필 페이지로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          child: Text('로그인'),
        ),
      ),
    );
  }
}

// 프로필 페이지
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '홍길동';
  String email = 'user123@example.com';
  String height = '180 cm';
  String weight = '75 kg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정', style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'), // 프로필 이미지
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: () {
                        // 사진 변경 기능 추가 예정
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.black), // 아이디 위의 검은 선
            _buildProfileItem('아이디', 'user123', null), // 아이디는 수정 버튼 없음
            _buildProfileItem('이름', name, () {
              _navigateToEditPage(context, '이름', name, (newValue) {
                setState(() {
                  name = newValue;
                });
              });
            }),
            _buildProfileItem('이메일', email, () {
              _navigateToEditPage(context, '이메일', email, (newValue) {
                setState(() {
                  email = newValue;
                });
              });
            }),
            _buildProfileItem('키', height, () {
              _navigateToEditPage(context, '키', height, (newValue) {
                setState(() {
                  height = newValue;
                });
              });
            }),
            _buildProfileItem('몸무게', weight, () {
              _navigateToEditPage(context, '몸무게', weight, (newValue) {
                setState(() {
                  weight = newValue;
                });
              });
            }),
            _buildProfileItem('성별', '남자', null), // 성별은 수정 버튼 없음
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 로그아웃 버튼을 누르면 로그인 화면으로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value, VoidCallback? onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
              if (onEdit != null) // 수정 버튼이 필요한 항목만 표시
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: onEdit,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 수정 페이지로 이동하는 함수
  void _navigateToEditPage(BuildContext context, String field, String currentValue, Function(String) onSave) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(
          field: field,
          currentValue: currentValue,
          onSave: onSave,
        ),
      ),
    );
  }
}

// 수정 페이지
class EditPage extends StatelessWidget {
  final String field;
  final String currentValue;
  final Function(String) onSave;

  EditPage({required this.field, required this.currentValue, required this.onSave});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = currentValue;

    return Scaffold(
      appBar: AppBar(
        title: Text('$field 수정'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '$field 입력',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onSave(_controller.text);
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
