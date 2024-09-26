import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // 앱 시작 시 로그인 페이지를 보여줌
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
            // 로그인 버튼을 누르면 메인 페이지로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.yellow,
            onPrimary: Colors.black,
          ),
          child: Text('로그인'),
        ),
      ),
    );
  }
}

// 메인 페이지
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 페이지', style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 버튼을 누르면 프로필 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.yellow,
            onPrimary: Colors.black,
          ),
          child: Text('프로필 페이지로 이동'),
        ),
      ),
    );
  }
}

// 프로필 페이지
class ProfilePage extends StatelessWidget {
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
            _buildProfileItem('이름', '홍길동', () {
              // 이름 수정 페이지로 이동하는 로직 추가
            }),
            _buildProfileItem('이메일', 'user123@example.com', () {
              // 이메일 수정 페이지로 이동하는 로직 추가
            }),
            _buildProfileItem('키', '180 cm', () {
              // 키 수정 페이지로 이동하는 로직 추가
            }),
            _buildProfileItem('몸무게', '75 kg', () {
              // 몸무게 수정 페이지로 이동하는 로직 추가
            }),
            _buildProfileItem('성별', '남자', null), // 성별은 수정 버튼 없음
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 로그아웃 버튼을 누르면 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // 로그아웃 버튼은 빨간색으로 설정
                  onPrimary: Colors.white,
                ),
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
}
