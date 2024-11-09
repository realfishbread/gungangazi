import 'package:flutter/material.dart';
 
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addDogMessage('안녕하세요! 어떤 증상이 있으신가요?'); // 강아지가 첫 메시지를 보냄
  }

  // 강아지가 한 글자씩 메시지를 보내는 메서드
  Future<void> _addDogMessage(String fullText) async {
    setState(() {
      _isTyping = true;
      _messages.add({
        'text': '', // 초기엔 빈 문자열로 추가
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

  // 사용자가 메시지를 보낼 때 호출
  void _sendMessage(bool isMine) {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _controller.text,
          'isMine': isMine,  // 내가 보낸 메시지인지 여부
        });
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 페이지'),
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
          if (_isTyping) // 강아지가 타이핑 중일 때 인디케이터 표시
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('강아지가 입력 중...'),
            ),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(true),  // 내 메시지
                ),
                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () => _addDogMessage('알겠습니다!'),  // 예시용 강아지 응답
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
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0), // 이미지를 아래로 내림
              child: Image.asset(
                'assets/dog.jpg', // 강아지 이미지 경로 설정
                width: 50,
                height: 50,
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6, // 텍스트 너비를 화면의 70%로 제한
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
              softWrap: true, // 텍스트 줄바꿈 허용
            ),
          ),
        ],
      ),
    );
  }
}

