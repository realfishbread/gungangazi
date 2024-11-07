import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../dto/userHealth/sleep_dto.dart';
import '../repositories/userHealth/sleep_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeUpTime;
  List<Map<String, String>> _sleepRecords = [];
  late final SleepRepository sleepRepository;

  @override
  void initState() {
    super.initState();
    sleepRepository = SleepRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _loadSleepDataFromServer(); // 초기화 시 서버에서 데이터 불러오기
  }

  // 서버에서 수면 데이터를 불러와 _sleepRecords에 추가하는 메서드
  Future<void> _loadSleepDataFromServer() async {
    List<SleepDto> serverData = await sleepRepository.fetchSleepDataFromDatabase();
    setState(() {
      _sleepRecords = serverData.map((dto) => {
        'date': dto.date,
        'sleepTime': dto.sleepTime,
        'wakeUpTime': dto.wakeUpTime,
      }).toList();
    });
  }

  // 로컬에 데이터 저장 후 서버로 즉시 전송
  Future<void> _saveSleepDataLocally() async {
    if (_sleepTime != null && _wakeUpTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Map<String, String> newRecord = {
        'date': formattedDate,
        'sleepTime': '${_sleepTime!.hour}:${_sleepTime!.minute}',
        'wakeUpTime': '${_wakeUpTime!.hour}:${_wakeUpTime!.minute}',
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

      // 로컬에 저장한 데이터를 서버로 바로 전송
      await _saveSleepDataToDatabase();
      // 서버에서 최신 데이터를 다시 불러와서 그래프에 반영
      await _loadSleepDataFromServer();
    } else {
      print('수면 시간 또는 기상 시간이 선택되지 않음');
    }
  }

  // 서버로 로컬 데이터를 전송하는 메서드
  Future<void> _saveSleepDataToDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sleepData');

    if (savedData != null) {
      try {
        List<dynamic> data = json.decode(savedData);
        List<SleepDto> records = data.map((item) {
          Map<String, String> record = Map<String, String>.from(item);
          return SleepDto(
            date: record['date']!,
            sleepTime: record['sleepTime']!,
            wakeUpTime: record['wakeUpTime']!,
          );
        }).toList();

        await sleepRepository.saveSleepDataToDatabase(records);
      } catch (e) {
        print('서버로 데이터를 전송하는 중 오류 발생: $e');
      }
    } else {
      print('로컬에 저장된 수면 데이터가 없습니다.');
    }
  }

  // 수면 기록 그래프 빌드 메서드 추가
  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('저장된 수면 기록이 없습니다.'));
    }

    List<BarChartGroupData> barGroups = _sleepRecords.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> record = entry.value;

      // 수면 시간과 기상 시간을 TimeOfDay 객체로 변환
      TimeOfDay sleepTime = TimeOfDay(
        hour: int.parse(record['sleepTime']!.split(":")[0]),
        minute: int.parse(record['sleepTime']!.split(":")[1]),
      );
      TimeOfDay wakeUpTime = TimeOfDay(
        hour: int.parse(record['wakeUpTime']!.split(":")[0]),
        minute: int.parse(record['wakeUpTime']!.split(":")[1]),
      );

      // 수면 지속 시간 계산
      Duration sleepDuration = _calculateSleepDuration(sleepTime, wakeUpTime);
      double sleepHours = sleepDuration.inMinutes / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sleepHours, // 수면 시간을 시간 단위로 설정
            color: Colors.blueAccent,
            width: 20,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4, // Y축 간격을 4시간 단위로 설정
              getTitlesWidget: (value, meta) => Text('${value.toInt()}h'), // Y축 레이블
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, meta) {
                return Text(_sleepRecords[value.toInt()]['date'] ?? ''); // X축 레이블 날짜
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false), // 테두리 비활성화
        minY: 0, // Y축 최소값
        maxY: 24, // Y축 최대값 (24시간)
      ),
    );
  }

  // 수면 지속 시간을 계산하는 헬퍼 메서드
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수면 정보'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Center(
        child: Container(
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
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectWakeUpTime(context),
                    icon: const Icon(Icons.wb_sunny),
                    label: Text(
                      _wakeUpTime == null
                          ? '기상 시간 선택'
                          : '기상 시간: ${_wakeUpTime!.format(context)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSleepDataLocally,
                child: const Text('로컬에 저장 및 서버 전송'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildSleepGraph(),
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
