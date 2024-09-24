// home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈 페이지'),
      ),
      body: Center(
        child: Text(
          '이곳은 tjfwjd입니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}