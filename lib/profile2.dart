import 'package:example4/loginPge.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위해 필요

class Profile2 extends StatefulWidget {
  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  // 기본값 설정
  String userId = 'user123';
  String name = '홍길동';
  String email = 'user123@example.com';
  String height = '180 cm';
  String weight = '75 kg';
  String gender = '남자';

  bool isLoading = true; // 데이터 로딩 상태를 나타냄

  @override
  void initState() {
    super.initState();
    // 프로필 정보를 가져옴
    fetchProfile();
  }

  // 서버에서 프로필 정보를 받아오는 함수
  Future<void> fetchProfile() async {
    try {
      final response = await http.get(Uri.parse('http://13.124.3.87/api/User.java')); //api url 적기

      if (response.statusCode == 200) {
        // 서버에서 받은 JSON 데이터를 파싱
        final data = json.decode(response.body);
        setState(() {
          userId = data['userId'];
          name = data['name'];
          email = data['email'];
          height = data['height'];
          weight = data['weight'];
          gender = data['gender'];
          isLoading = false; // 데이터 로딩 완료
        });
      } else {
        // 실패 시 기본값으로 유지 (별도 처리 없이 그냥 넘어감)
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // 예외 처리: 서버와의 통신에 실패할 경우
      setState(() {
        isLoading = false; // 로딩 중단
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFF9C4), // 타이틀 배경색 노란색
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중일 때 로딩 스피너 표시
          : Container(
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
            _buildProfileItem('아이디', userId, null),
            _buildProfileItem('이름', name, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '이름', currentValue: name, onSave: saveProfile),
                ),
              );
            }),
            _buildProfileItem('이메일', email, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '이메일', currentValue: email, onSave: saveProfile),
                ),
              );
            }),
            _buildProfileItem('키', height, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '키', currentValue: height, onSave: saveProfile),
                ),
              );
            }),
            _buildProfileItem('몸무게', weight, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPage(fieldName: '몸무게', currentValue: weight, onSave: saveProfile),
                ),
              );
            }),
            _buildProfileItem('성별', gender, null),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
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

  // 서버로 수정된 프로필 데이터를 보내는 함수
  Future<void> saveProfile(String fieldName, String newValue) async {
    final response = await http.put(
      Uri.parse('http://yourapi.com/api/profile/update'),// api url 적기
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        fieldName: newValue,
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 저장하면 프로필 정보를 다시 받아옴
      fetchProfile();
    } else {
      // 에러 처리
      throw Exception('Failed to save profile');
    }
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
  final Function(String fieldName, String newValue) onSave; // 수정된 값을 저장하는 콜백 함수

  EditPage({required this.fieldName, required this.currentValue, required this.onSave});

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
        backgroundColor: const Color(0xFFFFF9C4),
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
                // 수정된 값을 서버로 저장
                widget.onSave(widget.fieldName, _controller.text);
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

