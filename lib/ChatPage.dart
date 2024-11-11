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
  final Set<String> selectedSymptoms = {};
  final List<String> recentSymptoms = []; // 최근 검색된 증상 리스트
  final Dio _dio = Dio();
  bool _isTyping = false;

  // 서버 IP 주소 설정 (호스트 PC의 IP로 변경)
  final String serverUrl = 'https://gungangazi.site:5000';

  @override
  void initState() {
    super.initState();
    _addDogMessage('안녕하세요! 어떤 증상이 있으신가요?');
  }

  Future<void> _addDogMessage(String fullText) async {
    setState(() {
      _isTyping = true;
      _messages.add({
        'text': '',
        'isMine': false,
      });
    });

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
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
        final response = await _dio.post(
          '$serverUrl/predict_disease',
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: json.encode({'symptoms': selectedSymptoms.toList()}),
        );

        if (response.statusCode == 200) {
          final predictions = response.data['predictions'];
          final String resultText = predictions.map((pred) {
            return pred['disease'];
          }).join('\n');
          _showDiagnosisDialog(resultText); // 진단 결과를 다이얼로그로 표시

          setState(() {
            selectedSymptoms.clear(); // 진단 후 선택한 증상 초기화
          });
        } else {
          print("Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showDiagnosisDialog(String resultText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('진단 결과'),
        content: Text(resultText),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
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
      if (!recentSymptoms.contains(symptom)) {
        recentSymptoms.insert(0, symptom); // 최근 검색된 증상 리스트에 추가
        if (recentSymptoms.length > 5) {
          recentSymptoms.removeLast(); // 최대 5개까지만 유지
        }
      }
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
          if (_isTyping)
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
          if (recentSymptoms.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('최근 검색된 증상들:'),
            ),
            Wrap(
              children: recentSymptoms.map((symptom) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Chip(
                    label: Text(symptom),
                    backgroundColor: Colors.lightBlue[100],
                    onDeleted: () {
                      setState(() {
                        recentSymptoms.remove(symptom);
                      });
                    },
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedSymptoms.clear();
                    });
                  },
                  child: const Text("증상 목록 초기화"),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(true),
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
          if (!isMine)
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
