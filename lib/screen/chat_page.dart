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

  // 로컬 서버 URL 설정
  final String serverUrl = 'https://gunganghazi.site';

  @override
  void initState() {
    super.initState();
    _addDogMessage('안녕하시게나. 나는 건강아지 박사라네. 무슨 일이 있어 찾아왔는가?');
  }

  Future<void> _addDogMessage(String fullText) async {
    if (fullText.length <= 50) {
      // 짧은 메시지는 애니메이션 유지
      setState(() {
        _isTyping = true;
        _messages.add({'text': '', 'isMine': false});
      });

      for (int i = 0; i < fullText.length; i++) {
        await Future.delayed(const Duration(milliseconds: 30)); // 딜레이 단축
        setState(() {
          _messages.last['text'] = _messages.last['text'] + fullText[i];
        });
      }

      setState(() {
        _isTyping = false;
      });
    } else {
      // 긴 메시지는 즉시 출력
      setState(() {
        _messages.add({'text': fullText, 'isMine': false});
      });
    }
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
    if (selectedSymptoms.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': '입력된 증상: ${selectedSymptoms.join(', ')}',
          'isMine': true,
        });
      });

      try {
        final response = await _dio.post(
          '$serverUrl/predict_disease',
          options: Options(headers: {'Content-Type': 'application/json'}),
          data: json.encode({'symptoms': selectedSymptoms.toList()}),
        );

        if (response.statusCode == 200) {
          final predictions = response.data['predictions'];
          final showWarning = selectedSymptoms.length <= 2;

          if (predictions.isNotEmpty) {
            final diagnosisText = predictions.map((pred) {
              final disease = pred['disease'];
              return '$disease';
            }).join('\n');

            final resultMessage = '다음 질환들이 의심됩니다:\n$diagnosisText${showWarning ? '\n\n증상이 적을 경우 정확한 진단이 어려울 수 있습니다' : ''}';

            _addDogMessage(resultMessage);
          } else {
            _addDogMessage('입력된 증상으로는 진단할 수 있는 질환이 없습니다.');
          }

        } else {
          print("Error: ${response.statusCode}");
        }
      } catch (e) {
        print("Error: $e");
      }

      setState(() {
        selectedSymptoms.clear();
      });
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
        backgroundColor: const Color(0xFFFFF9C4), // 기존 AppBar 배경색 유지
      ),
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF9C4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  child: const Text("진단하기"),
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
                width: 70,
                height: 70,
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