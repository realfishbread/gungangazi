import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Health Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _symptomController = TextEditingController();
  String _result = "Enter symptoms and press Submit";

  // 백엔드에 증상 데이터를 POST하는 함수
  Future<void> _submitSymptoms() async {
    final symptoms = _symptomController.text.split(',').map((s) => s.trim()).toList();

    if (symptoms.isEmpty) {
      setState(() {
        _result = "Please enter some symptoms!";
      });
      return;
    }

    final url = Uri.parse('http://localhost:8080/callAI');  // 백엔드(Spring Boot) URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptoms': symptoms}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final diseases = data['diseases'];
        final probabilities = data['probabilities'];

        setState(() {
          _result = 'Diseases:\n';
          for (int i = 0; i < diseases.length; i++) {
            _result += '${diseases[i]} - ${probabilities[i]}%\n';
          }
        });
      } else {
        setState(() {
          _result = "Failed to fetch results from the server!";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Health Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                labelText: 'Enter symptoms (comma separated)',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitSymptoms,
              child: Text('Submit'),
            ),
            SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
