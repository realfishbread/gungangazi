import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../dto/userHealth/sleep_dto.dart';
import '../repositories/userHealth/sleep_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart';

class SleepPage extends StatefulWidget {
  final PopupHandler popupHandler;
  
   const SleepPage({Key? key, required this.popupHandler}) : super(key: key);
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
    _loadSleepDataFromServer();
  }

  // Fetch sleep data from the server and update _sleepRecords
  Future<void> _loadSleepDataFromServer() async {
    List<SleepDto> serverData = await sleepRepository.fetchSleepDataFromDatabase();
    setState(() {
      _sleepRecords = serverData.map((dto) => {
        'date': dto.date,
        'sleepTime': dto.sleepTime,
        'wakeUpTime': dto.wakeUpTime,
        'username': dto.username,
      }).toList();
    });
    print('_sleepRecords: $_sleepRecords'); // Debugging print
  }

  // Save sleep data directly to the server
Future<void> _saveSleepDataToServer() async {
  if (_sleepTime != null && _wakeUpTime != null) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Duration sleepDuration = _calculateSleepDuration(_sleepTime!, _wakeUpTime!);
    double sleepHours = sleepDuration.inMinutes / 60.0;

    // 수면 시간이 5시간 이상일 때 PopupHandler의 sleepLevel을 증가
    if (sleepHours >= 5.0) {
      widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: widget.popupHandler.mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel + 200,
  );
  print("Sleep saved and PopupHandler status updated - Sleep Level: ${widget.popupHandler.sleepLevel}");
}

    // 서버에 저장할 SleepDto 데이터 생성
    String? username = await TokenService().getUsername();
    SleepDto newSleepRecord = SleepDto(
      date: formattedDate,
      sleepTime: '${_sleepTime!.hour}:${_sleepTime!.minute}:00',
      wakeUpTime: '${_wakeUpTime!.hour}:${_wakeUpTime!.minute}:00',
      username: username ?? 'defaultUser', // Replace with actual username
    );

    try {
      // 서버에 데이터 저장
      await sleepRepository.saveSleepDataToDatabase([newSleepRecord]);
      print('Successfully saved sleep data to the server');
    } catch (e) {
      print('Error sending data to the server: $e');
    }
  } else {
    print('Sleep time or wake-up time is not selected');
  }
}


  Widget _buildSleepGraph() {
  if (_sleepRecords.isEmpty) {
    return const Center(child: Text('저장된 수면 기록이 없습니다.'));
  }

  List<BarChartGroupData> barGroups = _sleepRecords.asMap().entries.map((entry) {
    int index = entry.key;
    Map<String, String> record = entry.value;

    // 수면 및 기상 시간을 TimeOfDay로 변환
    TimeOfDay sleepTime = TimeOfDay(
      hour: int.parse(record['sleepTime']!.split(":")[0]),
      minute: int.parse(record['sleepTime']!.split(":")[1]),
    );
    TimeOfDay wakeUpTime = TimeOfDay(
      hour: int.parse(record['wakeUpTime']!.split(":")[0]),
      minute: int.parse(record['wakeUpTime']!.split(":")[1]),
    );

    // 수면 시간 계산
    Duration sleepDuration = _calculateSleepDuration(sleepTime, wakeUpTime);
    double sleepHours = sleepDuration.inMinutes / 60.0;

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: sleepHours,
          color: Colors.blueAccent,
          width: 20,
        ),
      ],
    );
  }).toList();

  // 권장 수면 시간 (예: 8시간)
  double recommendedSleepHours = 8.0;

  return BarChart(
    BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 4,
            getTitlesWidget: (value, meta) => Text('${value.toInt()}h'),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, meta) {
              return Text(_sleepRecords[value.toInt()]['date'] ?? '');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 24,
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: recommendedSleepHours,
            color: Colors.red,
            strokeWidth: 2,
            dashArray: [5, 5],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topLeft,
              labelResolver: (line) => '권장 수면 시간: ${recommendedSleepHours.toInt()}h',
            ),
          ),
        ],
      ),
    ),
  );
}
  // Helper method to calculate sleep duration
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
  return WillPopScope(
    onWillPop: () async {
      // 수면 상태가 증가했는지 확인하고 애니메이션 실행
      if (widget.popupHandler.sleepLevel > widget.popupHandler.sleepLevelThreshold) {
        widget.popupHandler.triggerAnimation('sleeping', delayMilliseconds: 1000);
      } else {
        print("No significant sleep level change, no animation triggered.");
      }

      // 뒤로 가기 동작 허용
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('수면'),
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
                          ? '취침 시각 선택'
                          : 'Sleep Time: ${_sleepTime!.format(context)}',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectWakeUpTime(context),
                    icon: const Icon(Icons.wb_sunny),
                    label: Text(
                      _wakeUpTime == null
                          ? '기상 시각 선택'
                          : 'Wake-up Time: ${_wakeUpTime!.format(context)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSleepDataToServer,
                child: const Text('저장'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildSleepGraph(),
              ),
            ],
          ),
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
