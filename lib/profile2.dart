import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      theme: ThemeData(
        primaryColor: Colors.yellow,
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 페이지', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow, // 타이틀 배경색 노란색
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            // 프로필 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          child: Text('프로필 페이지로 이동', style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow, // 타이틀 배경색 노란색
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
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
            Divider(color: Colors.black),
            _buildProfileItem('아이디', 'user123', null),
            _buildProfileItem('이름', '홍길동', () {
              // 이름 수정 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '이름', currentValue: '홍길동'),
                ),
              );
            }),
            _buildProfileItem('이메일', 'user123@example.com', () {
              // 이메일 수정 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '이메일', currentValue: 'user123@example.com'),
                ),
              );
            }),
            _buildProfileItem('키', '180 cm', () {
              // 키 수정 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '키', currentValue: '180 cm'),
                ),
              );
            }),
            _buildProfileItem('몸무게', '75 kg', () {
              // 몸무게 수정 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '몸무게', currentValue: '75 kg'),
                ),
              );
            }),
            _buildProfileItem('성별', '남자', null),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // 로그아웃 버튼을 누르면 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('로그아웃', style: TextStyle(color: Colors.black)),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black),
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
}

// 수정 페이지
class EditPage extends StatefulWidget {
  final String fieldName;
  final String currentValue;

  EditPage({required this.fieldName, required this.currentValue});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fieldName} 수정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow, // 타이틀 배경색 노란색
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '${widget.fieldName}',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // 수정된 값을 저장하고 프로필 페이지로 돌아감
                Navigator.pop(context);
              },
              child: Text('저장', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
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
        title: Text('로그인', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow, // 타이틀 배경색 노란색
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '로그인 페이지',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
