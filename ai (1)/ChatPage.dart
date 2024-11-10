import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  List<String> relatedSymptoms = [];
  final Set<String> selectedSymptoms = {}; // Set 사용으로 중복 방지
  final Dio _dio = Dio(); // Dio instance 생성

  // 서버 IP 주소 설정 (호스트 PC의 IP로 변경)
  final String serverUrl = 'http://127.0.0.1:5000';

  Future<void> fetchRelatedSymptoms(String symptom) async {
    try {
      final response = await _dio.post(
        '$serverUrl/similar_symptoms',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode({'symptoms': [symptom]}),
      );

      if (response.statusCode == 200) {
        setState(() {
          relatedSymptoms = List<String>.from(response.data)..sort();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> diagnoseDisease() async {
    try {
      // 선택된 증상을 채팅창에 출력
      if (selectedSymptoms.isNotEmpty) {
        setState(() {
          _messages.add({
            'text': '입력된 증상: ${selectedSymptoms.join(', ')}',
            'isMine': true,
          });
        });
      }

      final response = await _dio.post(
        '$serverUrl/predict_disease',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode({'symptoms': selectedSymptoms.toList()}),
      );

      if (response.statusCode == 200) {
        final predictions = response.data['predictions'];
        final showWarning = selectedSymptoms.length <= 2; // 입력된 증상이 3개 이하인지 확인

        setState(() {
          if (predictions.length == 1) {
            // 하나의 결과만 있는 경우
            final disease = predictions[0]['disease'];
            _messages.add({
              'text': '해당 증상으로는 다음 질환이 의심됩니다:\n$disease' +
                  (showWarning ? '\n\n증상이 적을 경우 정확한 진단이 어려울 수 있습니다' : ''),
              'isMine': false,
            });
          } else {
            // 여러 결과가 있는 경우
            final diagnosisText = predictions.map((pred) {
              final disease = pred['disease'];
              return '$disease';
            }).join('\n');

            _messages.add({
              'text': '다음 질환들이 의심됩니다:\n$diagnosisText' +
                  (showWarning ? '\n\n증상이 적을 경우 정확한 진단이 어려울 수 있습니다' : ''),
              'isMine': false,
            });
          }

          // 선택된 증상 초기화
          selectedSymptoms.clear();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _sendMessage(bool isMine) {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _controller.text,
          'isMine': isMine,
        });
        _controller.clear();
        relatedSymptoms = [];
      });
    }
  }

  void addSymptom(String symptom) {
    setState(() {
      selectedSymptoms.add(symptom);
      _controller.clear();
      relatedSymptoms = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('증상 채팅'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  text: message['text'],
                  isMine: message['isMine'],
                );
              },
            ),
          ),

          // 선택된 증상 목록
          Wrap(
            children: selectedSymptoms.map((symptom) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Chip(
                  label: Text(symptom),
                  backgroundColor: Colors.yellow[200],
                  onDeleted: () { // 선택된 증상 해제 기능
                    setState(() {
                      selectedSymptoms.remove(symptom);
                    });
                  },
                ),
              );
            }).toList(),
          ),

          // 연관 증상 목록 (버튼으로 표시)
          if (relatedSymptoms.isNotEmpty) ...[
            Wrap(
              children: relatedSymptoms.map((symptom) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    key: ValueKey(symptom), // 고유한 키 추가
                    onPressed: () {
                      addSymptom(symptom);
                    },
                    child: Text(symptom),
                  ),
                );
              }).toList(),
            ),
          ],

          // 입력 창과 버튼들
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // 증상 입력 필드
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '증상을 입력하세요',
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        fetchRelatedSymptoms(text);
                      } else {
                        setState(() {
                          relatedSymptoms = [];
                        });
                      }
                    },
                  ),
                ),
                // 진단하기 버튼
                ElevatedButton(
                  onPressed: () {
                    diagnoseDisease();
                  },
                  child: Text("진단하기"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMine;

  const ChatBubble({super.key, required this.text, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMine ? Colors.yellow[200] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMine ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: isMine ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
