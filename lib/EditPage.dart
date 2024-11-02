import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  final String fieldName; // 수정할 필드의 이름
  final String currentValue; // 현재 값
  final Function(String fieldName, String newValue) onSave; // 수정된 값을 저장하는 콜백 함수

  const EditPage({
    super.key,
    required this.fieldName,
    required this.currentValue,
    required this.onSave,
  });

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _controller;
  bool _isSaving = false; // 저장 중인지 여부를 나타내는 상태

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  Future<void> _saveProfile() async {
    if (_controller.text.isEmpty) {
      // 입력값이 비어있을 때 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('값을 입력해주세요.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isSaving = true; // 저장 중 상태 설정
    });

    await widget.onSave(widget.fieldName, _controller.text); // 수정된 값 저장

    setState(() {
      _isSaving = false; // 저장 완료 상태로 변경
    });

    Navigator.pop(context); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fieldName} 수정', style: const TextStyle(color: Colors.black)),
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
                labelText: widget.fieldName,
                labelStyle: const TextStyle(color: Colors.black),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
              onSubmitted: (value) => _saveProfile(), // 엔터키 입력 시 자동 저장
            ),
            const SizedBox(height: 20),
            _isSaving
                ? const CircularProgressIndicator() // 저장 중일 때 로딩 스피너 표시
                : TextButton(
                    onPressed: _saveProfile,
                    child: const Text('저장', style: TextStyle(color: Colors.black)),
                  ),
          ],
        ),
      ),
    );
  }
}
