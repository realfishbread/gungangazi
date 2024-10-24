import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

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
    _loadSleepData();
  }

  Future<void> _saveSleepDataLocally() async {
    if (_sleepTime != null && _wakeUpTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 시간을 24시간 형식으로 저장
      Map<String, String> newRecord = {
        'date': formattedDate,
        'sleepTime': '${_sleepTime!.hour}:${_sleepTime!.minute}',  // 시간 형식 수정
        'wakeUpTime': '${_wakeUpTime!.hour}:${_wakeUpTime!.minute}',  // 시간 형식 수정
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('sleepData');
      List<Map<String, String>> records = [];

      if (savedData != null) {
        try {
          List<dynamic> decodedData = json.decode(savedData);
          records = decodedData.map((item) {
            return Map<String, String>.from(item);
          }).toList();
        } catch (e) {
          print('저장된 데이터를 불러오는 중 오류 발생: $e');
        }
      }

      bool recordExists = false;
      for (int i = 0; i < records.length; i++) {
        if (records[i]['date'] == formattedDate) {
          records[i] = newRecord;
          recordExists = true;
          break;
        }
      }

      if (!recordExists) {
        records.add(newRecord);
      }

      await prefs.setString('sleepData', json.encode(records));
      print('수면 데이터 로컬에 저장 성공: $records');
      _loadSleepData();
    } else {
      print('수면 시간 또는 기상 시간이 선택되지 않음');
    }
  }

  Future<void> _saveSleepDataToDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sleepData');

    if (savedData != null) {
      try {
        List<dynamic> data = json.decode(savedData);
        List<Map<String, String>> records = data.map((item) {
          return Map<String, String>.from(item);
        }).toList();

        final response = await http.post(
          Uri.parse('https://gungangazi.site/saveSleepData'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'records': records}),
        );

        if (response.statusCode == 200) {
          print('수면 데이터가 서버에 성공적으로 저장되었습니다.');
        } else {
          print('서버에 데이터 저장 실패: ${response.statusCode}');
        }
      } catch (e) {
        print('서버로 데이터를 전송하는 중 오류 발생: $e');
      }
    } else {
      print('로컬에 저장된 수면 데이터가 없습니다.');
    }
  }

  Future<void> _loadSleepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sleepData');

    if (savedData != null) {
      try {
        List<dynamic> data = json.decode(savedData);
        setState(() {
          _sleepRecords = data.map((item) {
            return Map<String, String>.from(item);
          }).toList();
        });
        print('수면 데이터 로드 성공: $_sleepRecords');
      } catch (e) {
        print('수면 데이터를 로드하는 중 오류 발생: $e');
        setState(() {
          _sleepRecords = [];
        });
      }
    } else {
      setState(() {
        _sleepRecords = [];
      });
    }
  }

  Duration _calculateSleepDuration(TimeOfDay sleepTime, TimeOfDay wakeUpTime) {
    final now = DateTime.now();

    final sleepDateTime = DateTime(now.year, now.month, now.day, sleepTime.hour, sleepTime.minute);
    final wakeUpDateTime = DateTime(now.year, now.month, now.day, wakeUpTime.hour, wakeUpTime.minute);

    if (wakeUpDateTime.isBefore(sleepDateTime)) {
      return wakeUpDateTime.add(const Duration(days: 1)).difference(sleepDateTime);
    } else {
      return wakeUpDateTime.difference(sleepDateTime);
    }
  }

  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('저장된 수면 기록이 없습니다.'));
    }

    List<BarChartGroupData> barGroups = _sleepRecords.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> record = entry.value;

      TimeOfDay sleepTime = TimeOfDay(
        hour: int.parse(record['sleepTime']!.split(":")[0]),
        minute: int.parse(record['sleepTime']!.split(":")[1]),
      );
      TimeOfDay wakeUpTime = TimeOfDay(
        hour: int.parse(record['wakeUpTime']!.split(":")[0]),
        minute: int.parse(record['wakeUpTime']!.split(":")[1]),
      );

      Duration sleepDuration = _calculateSleepDuration(sleepTime, wakeUpTime);
      double sleepHours = sleepDuration.inMinutes / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sleepHours.toInt().toDouble(), // 소수점 없는 정수 값으로 변환
            color: Colors.blueAccent,
            width: 20,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups, // 막대 데이터 리스트
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4, // y축 레이블 간격 (4시간 단위)
              getTitlesWidget: (value, meta) => Text('${value.toInt()}h'), // y축 레이블 (0~24시간)
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, meta) {
                return Text(_sleepRecords[value.toInt()]['date'] ?? ''); // x축 레이블: 날짜
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false), // 테두리 비활성화
        minY: 0, // y축 최소값 (0시간)
        maxY: 24, // y축 최대값 (24시간)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isWeb = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('수면 정보'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Center(
        child: Container(
          width: isWeb ? 800 : screenSize.width,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _selectSleepTime(context),
                    icon: const Icon(Icons.bedtime),
                    label: Text(
                      _sleepTime == null
                          ? '수면 시간 선택'
                          : '수면 시간: ${_sleepTime!.format(context)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(140, 40),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectWakeUpTime(context),
                    icon: const Icon(Icons.wb_sunny),
                    label: Text(
                      _wakeUpTime == null
                          ? '기상 시간 선택'
                          : '기상 시간: ${_wakeUpTime!.format(context)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(140, 40),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSleepDataLocally,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  minimumSize: const Size(140, 40),
                ),
                child: const Text('로컬에 저장하기'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildSleepGraph(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _saveSleepDataToDatabase,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    minimumSize: const Size(140, 40),
                  ),
                  child: const Text('데이터베이스로 전송하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectSleepTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _sleepTime) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }

  Future<void> _selectWakeUpTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }
}
