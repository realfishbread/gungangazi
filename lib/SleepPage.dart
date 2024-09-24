import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SleepPage extends StatefulWidget {
  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeUpTime;
  List<Map<String, String>> _sleepRecords = [];

  // 서버로 수면 시간 저장
  Future<void> _saveSleepData() async {
    if (_sleepTime != null && _wakeUpTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String formattedSleepTime = _sleepTime!.format(context);
      String formattedWakeUpTime = _wakeUpTime!.format(context);

      var url = Uri.parse('http://localhost:8080/api/sleep/add');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'date': formattedDate,
          'sleepTime': formattedSleepTime,
          'wakeUpTime': formattedWakeUpTime,
        }),
      );

      if (response.statusCode == 200) {
        print('수면 데이터 저장 성공');
        _loadSleepData(); // 저장 후 새로고침
      } else {
        print('저장 실패');
      }
    }
  }

  // 서버에서 수면 데이터 가져오기
  Future<void> _loadSleepData() async {
    var url = Uri.parse('http://localhost:8080/api/sleep/all');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _sleepRecords = data
            .map((record) => {
          'date': record['date'] as String,
          'sleepTime': record['sleepTime'] as String,
          'wakeUpTime': record['wakeUpTime'] as String,
        })
            .toList();
      });
    } else {
      print('데이터 불러오기 실패');
    }
  }

  // 초기화 시 서버에서 데이터 로드
  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수면 정보'),
        backgroundColor: Color(0xFFFFF9C4),
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
                  style: ElevatedButton.styleFrom(
                  ),
                  child: Text(_sleepTime == null
                      ? '수면 시간 선택'
                      : '수면 시간: ${_sleepTime!.format(context)}'),
                ),
                ElevatedButton(
                  onPressed: () => _selectWakeUpTime(context),
                  style: ElevatedButton.styleFrom(
                  ),
                  child: Text(_wakeUpTime == null
                      ? '기상 시간 선택'
                      : '기상 시간: ${_wakeUpTime!.format(context)}'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSleepData,
              style: ElevatedButton.styleFrom(
              ),
              child: Text('저장하기'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _sleepRecords.isEmpty
                  ? Center(child: Text('저장된 수면 기록이 없습니다.'))
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
