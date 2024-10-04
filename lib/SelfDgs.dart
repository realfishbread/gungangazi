import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelfDgs extends StatefulWidget {
  @override
  _SelfDgsState createState() =>  _SelfDgsState();
}

class _SelfDgsState extends State<SelfDgs> {
  int currentQuestionNumber = 1;
  String questionText = '';
  List<String> options = [];
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    fetchQuestion(currentQuestionNumber);
  }

  Future<void> fetchQuestion(int questionNumber) async {
    final response = await http.get(Uri.parse('http://yourapiurl.com/questions/$questionNumber'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        questionText = data['questionText'];
        options = List<String>.from(data['options']);
        selectedOption = null;
      });
    } else {
      // 에러 처리
    }
  }

  void goToNextQuestion() {
    setState(() {
      currentQuestionNumber++;
    });
    fetchQuestion(currentQuestionNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문항 선택'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(questionText),
          ...options.map((option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });
            },
          )),
          ElevatedButton(
            onPressed: selectedOption != null ? goToNextQuestion : null,
            child: Text('다음'),
          ),
        ],
      ),
    );
  }
}
