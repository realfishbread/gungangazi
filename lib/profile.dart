import 'package:flutter/material.dart';

class Profilepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Settings',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(), // 처음에 프로필 페이지로 이동
    );
  }
}

// 프로필 페이지
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _height = '';
  String _weight = '';
  String _gender = ''; // 기본값으로 성별 표시

  // 수정 페이지로 이동하고 값을 반환 받는 함수
  Future<void> _navigateAndModify(BuildContext context, String field, String currentValue) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPage(field: field, currentValue: currentValue)),
    );

    if (result != null && result is String) {
      setState(() {
        if (field == '이름') {
          _name = result;
        } else if (field == '키') {
          _height = result;
        } else if (field == '몸무게') {
          _weight = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // 이름 표시 + 수정 버튼
            Row(
              children: [
                Text(
                  '이름: $_name',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateAndModify(context, '이름', _name),
                  child: Text('수정'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 키 표시 + 수정 버튼
            Row(
              children: [
                Text(
                  '키: $_height cm',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateAndModify(context, '키', _height),
                  child: Text('수정'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 몸무게 표시 + 수정 버튼
            Row(
              children: [
                Text(
                  '몸무게: $_weight kg',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateAndModify(context, '몸무게', _weight),
                  child: Text('수정'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 성별 표시 (수정 버튼 없음)
            Text(
              '성별: $_gender',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(), // 로그아웃 버튼을 화면 아래에 배치하기 위한 Spacer
            // 메인 페이지로 돌아가는 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 메인 페이지로 돌아가기
                },
                child: Text('메인 페이지로 돌아가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 수정 페이지
class EditPage extends StatefulWidget {
  final String field;
  final String currentValue;

  EditPage({required this.field, required this.currentValue});

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
        title: Text('${widget.field} 수정'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '${widget.field} 입력',
                border: OutlineInputBorder(),
              ),
              keyboardType: widget.field == '키' || widget.field == '몸무게'
                  ? TextInputType.number
                  : TextInputType.text,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text); // 수정된 값 반환
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
