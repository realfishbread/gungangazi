import 'package:flutter/material.dart';
import 'dart:async';




// 프로필 페이지
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _height = '';
  String _weight = '';
  final String _gender = ''; // 기본값으로 성별 표시

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
        title: const Text('프로필 설정'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 이름 표시 + 수정 버튼
            Row(
              children: [
                Text(
                  '이름: $_name',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateAndModify(context, '이름', _name),
                  child: const Text('수정'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 키 표시 + 수정 버튼
            Row(
              children: [
                Text(
                  '키: $_height cm',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateAndModify(context, '키', _height),
                  child: const Text('수정'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 몸무게 표시 + 수정 버튼
            Row(
              children: [
                Text(
                  '몸무게: $_weight kg',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateAndModify(context, '몸무게', _weight),
                  child: const Text('수정'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 성별 표시 (수정 버튼 없음)
            Text(
              '성별: $_gender',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(), // 로그아웃 버튼을 화면 아래에 배치하기 위한 Spacer
            // 메인 페이지로 돌아가는 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 메인 페이지로 돌아가기
                },
                child: const Text('메인 페이지로 돌아가기'),
              ),
            ),
            const SizedBox(height: 16),
            // 로그아웃 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 로그아웃 기능을 구현할 때 여기에 코드 추가
                },
                child: const Text('로그아웃'),
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

  const EditPage({super.key, required this.field, required this.currentValue});

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
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '${widget.field} 입력',
                border: const OutlineInputBorder(),
              ),
              keyboardType: widget.field == '키' || widget.field == '몸무게'
                  ? TextInputType.number
                  : TextInputType.text,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text); // 수정된 값 반환
              },
              child: const Text('저장'),
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