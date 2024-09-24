import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeUpTime;
  List<Map<String, String>> _sleepRecords = [];

  @override
  void initState() {
    super.initState();
    _loadSleepData(); // 앱 시작 시 데이터 로드
  }

  // 수면 시간 저장
  Future<void> _saveSleepData() async {
    if (_sleepTime != null && _wakeUpTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String formattedSleepTime = _sleepTime!.format(context);
      String formattedWakeUpTime = _wakeUpTime!.format(context);

      // 새로운 기록을 저장할 데이터로 변환
      Map<String, String> newRecord = {
        'date': formattedDate,
        'sleepTime': formattedSleepTime,
        'wakeUpTime': formattedWakeUpTime,
      };

      // SharedPreferences 인스턴스 생성
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 이전에 저장된 데이터를 불러오기
      String? savedData = prefs.getString('sleepData');
      List<Map<String, String>> records = [];

      if (savedData != null) {
        // 저장된 데이터가 있다면 이를 리스트로 변환
        List<dynamic> decodedData = json.decode(savedData);
        records = List<Map<String, String>>.from(decodedData);
      }

      // 새로운 기록을 리스트에 추가
      records.add(newRecord);

      // 업데이트된 리스트를 다시 저장
      await prefs.setString('sleepData', json.encode(records));

      print('수면 데이터 저장 성공');

      // 저장 후 데이터 다시 로드
      _loadSleepData();
    }
  }

  // 로컬에서 수면 데이터 가져오기
  Future<void> _loadSleepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sleepData');

    if (savedData != null) {
      // 저장된 데이터를 디코딩하여 리스트로 변환
      List<dynamic> data = json.decode(savedData);
      setState(() {
        _sleepRecords = List<Map<String, String>>.from(data);
      });
    } else {
      setState(() {
        _sleepRecords = [];
      });
    }
  }

  // 수면 시간을 차트에 사용할 수 있도록 변환
  List<Map<String, double>> _convertSleepRecordsToChartData() {
    List<Map<String, double>> chartData = [];
    for (var record in _sleepRecords) {
      TimeOfDay sleepTime = _parseTime(record['sleepTime']!);
      TimeOfDay wakeUpTime = _parseTime(record['wakeUpTime']!);

      chartData.add({
        'sleep': sleepTime.hour + sleepTime.minute / 60,
        'wakeUp': wakeUpTime.hour + wakeUpTime.minute / 60,
      });
    }
    return chartData;
  }

  // 문자열로 된 시간 데이터를 TimeOfDay로 변환
  TimeOfDay _parseTime(String timeString) {
    final format = DateFormat.jm(); // 'h:mm a' 형식
    return TimeOfDay.fromDateTime(format.parse(timeString));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수면 정보'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _selectSleepTime(context),
                  style: ElevatedButton.styleFrom(),
                  child: Text(_sleepTime == null
                      ? '수면 시간 선택'
                      : '수면 시간: ${_sleepTime!.format(context)}'),
                ),
                ElevatedButton(
                  onPressed: () => _selectWakeUpTime(context),
                  style: ElevatedButton.styleFrom(),
                  child: Text(_wakeUpTime == null
                      ? '기상 시간 선택'
                      : '기상 시간: ${_wakeUpTime!.format(context)}'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSleepData,
              style: ElevatedButton.styleFrom(),
              child: const Text('저장하기'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _sleepRecords.isEmpty
                  ? const Center(child: Text('저장된 수면 기록이 없습니다.'))
                  : SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('날짜')),
                    DataColumn(label: Text('수면 시간')),
                    DataColumn(label: Text('기상 시간')),
                  ],
                  rows: _sleepRecords.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record['date']!)),
                      DataCell(Text(record['sleepTime']!)),
                      DataCell(Text(record['wakeUpTime']!)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 수면 시간 선택
  Future<void> _selectSleepTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != _sleepTime) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }

  // 기상 시간 선택
  Future<void> _selectWakeUpTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }
}
