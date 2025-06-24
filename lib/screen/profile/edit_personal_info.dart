import 'package:flutter/material.dart';

class EditPersonalInfo extends StatefulWidget {
  final String fieldName; // 수정할 필드의 이름
  final String currentValue; // 현재 값 (숫자만)
  final Function(String fieldName, String newValue) onSave; // 수정된 값을 저장하는 콜백 함수

  const EditPersonalInfo({
    super.key,
    required this.fieldName,
    required this.currentValue,
    required this.onSave,
  });

  @override
  _EditPersonalInfoState createState() => _EditPersonalInfoState();
}

class _EditPersonalInfoState extends State<EditPersonalInfo> {
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

     // 단위를 붙여서 저장 (키, 몸무게, 나이에 단위 추가)
    String newValue;
    if (widget.fieldName == '키') {
      newValue = '${_controller.text}cm'; // 키에 cm 단위 추가
    } else if (widget.fieldName == '몸무게') {
      newValue = '${_controller.text}kg'; // 몸무게에 kg 단위 추가
    } else if (widget.fieldName == '나이') {
      newValue = '${_controller.text}세'; // 나이에 "세" 단위 추가
    } else {
      newValue = _controller.text; // 나머지 필드는 그대로 저장
    }

    await widget.onSave(widget.fieldName, newValue); // 수정된 값 저장

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.fieldName,
                      labelStyle: const TextStyle(color: Colors.black),
                      border: const OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onSubmitted: (value) => _saveProfile(), // 엔터키 입력 시 자동 저장
                  ),
                ),
                const SizedBox(width: 8),
                // 키, 몸무게, 나이에 단위 표시
                if (widget.fieldName == '키' || widget.fieldName == '몸무게' || widget.fieldName == '나이')
                  Text(
                    widget.fieldName == '키'
                        ? 'cm'
                        : widget.fieldName == '몸무게'
                            ? 'kg'
                            : '세', // '나이' 필드에는 '세' 추가
                    style: const TextStyle(fontSize: 18),
                  ),
              ],
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
