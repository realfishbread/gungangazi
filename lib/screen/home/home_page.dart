import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈페이지'),
        backgroundColor: const Color(0xFFFFF9C4),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '환영합니다! 여기는 홈페이지입니다.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
