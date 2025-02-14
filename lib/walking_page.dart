import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class WalkingPage extends StatefulWidget {
  @override
  _WalkingPageState createState() => _WalkingPageState();
}

class _WalkingPageState extends State<WalkingPage> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen((StepCount event) {
      setState(() {
        _steps = event.steps;
      });
    }).onError((error) {
      print("걸음 수 측정 에러: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('만보기'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '현재 걸음 수',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '$_steps 걸음',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            SizedBox(height: 20),
            Icon(Icons.directions_walk, size: 100, color: Colors.purpleAccent),
          ],
        ),
      ),
    );
  }
}
