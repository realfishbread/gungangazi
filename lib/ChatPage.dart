import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  List<String> relatedSymptoms = [];
  final Set<String> selectedSymptoms = {}; // Set 사용으로 중복 방지
  final Dio _dio = Dio(); // Dio instance 생성
  bool _isTyping = false;

  // 서버 IP 주소 설정 (호스트 PC의 IP로 변경)
  final String serverUrl = 'http://127.0.0.1:5000';

  @override
  void initState() {
    super.initState();
    _addDogMessage('안녕하세요! 어떤 증상이 있으신가요?');
  }

  // 강아지가 한 글자씩 메시지를 보내는 메서드
  Future<void> _addDogMessage(String fullText) async {
    setState(() {
      _isTyping = true;
      _messages.add({
        'text': '',
        'isMine': false,
      });
    });

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100)); // 글자 하나당 100ms 지연
      setState(() {
        _messages.last['text'] = _messages.last['text'] + fullText[i];
      });
    }

    setState(() {
      _isTyping = false;
    });
  }

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
        final showWarning = selectedSymptoms.length <= 2;

        setState(() {
          if (predictions.length == 1) {
            final disease = predictions[0]['disease'];
            _messages.add({
              'text': '해당 증상으로는 다음 질환이 의심됩니다:\n$disease' +
                  (showWarning ? '\n\n증상이 적을 경우 정확한 진단이 어려울 수 있습니다' : ''),
              'isMine': false,
            });
          } else {
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
        backgroundColor: const Color(0xFFFFF9C4),
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
          if (_isTyping) // 강아지가 타이핑 중일 때 인디케이터 표시
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('강아지가 입력 중...'),
            ),
          Wrap(
            children: selectedSymptoms.map((symptom) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Chip(
                  label: Text(symptom),
                  backgroundColor: Colors.yellow[200],
                  onDeleted: () {
                    setState(() {
                      selectedSymptoms.remove(symptom);
                    });
                  },
                ),
              );
            }).toList(),
          ),
          if (relatedSymptoms.isNotEmpty) ...[
            Wrap(
              children: relatedSymptoms.map((symptom) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      addSymptom(symptom);
                    },
                    child: Text(symptom),
                  ),
                );
              }).toList(),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
                ElevatedButton(
                  onPressed: () {
                    diagnoseDisease();
                  },
                  child: const Text("진단하기"),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(true),
                ),
                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () => _addDogMessage('알겠습니다!'),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) // 상대방 메시지일 때 강아지 이미지 추가
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: Image.asset(
                'assets/dog.jpg',
                width: 50,
                height: 50,
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
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
              style: const TextStyle(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
