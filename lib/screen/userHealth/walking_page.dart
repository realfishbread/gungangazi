import 'package:flutter/material.dart';

import '../../core_services/health_connect_service.dart'; // ✅ HealthConnectService 추가

class WalkingPage extends StatefulWidget {
  @override
  _WalkingPageState createState() => _WalkingPageState();
}

class _WalkingPageState extends State<WalkingPage> {

  
  int _healthConnectSteps = 0;
  final HealthConnectService _healthService = HealthConnectService();

  @override
  void initState() {
    super.initState();
    fetchHealthConnectSteps(); // ✅ Health Connect 걸음 수 가져오기
  }

  

  void fetchHealthConnectSteps() async {
    int steps = await _healthService.fetchSteps();
    setState(() {
      _healthConnectSteps = steps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('만보기'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('현재 걸음 수', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Health Connect: $_healthConnectSteps 걸음', style: TextStyle(fontSize: 30, color: Colors.blue)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchHealthConnectSteps, // ✅ Health Connect 데이터 새로고침 버튼
              child: Text("Health Connect 데이터 새로고침"),
            ),
          ],
        ),
      ),
    );
  }
}