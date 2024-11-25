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
  int _currentSleepLevel = 0; // 현재 sleepLevel 저장

  @override
  void initState() {
    super.initState();
    sleepRepository = SleepRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _loadSleepDataFromServer();
    _currentSleepLevel = widget.popupHandler.sleepLevel;
  }

  // Fetch sleep data from the server and update _sleepRecords
  Future<void> _loadSleepDataFromServer() async {
    List<SleepDto> serverData = await sleepRepository.fetchSleepDataFromDatabase();
    setState(() {
      _sleepRecords = serverData.map((dto) => {
        'date': dto.date,
        'sleep_time': dto.sleep_time,
        'wake_up_time': dto.wake_up_time,
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

      // 새로운 sleepLevel 계산
      int newSleepLevel = widget.popupHandler.sleepLevel;
      _currentSleepLevel = widget.popupHandler.sleepLevel;
      if (sleepHours >= 5.0) {
        newSleepLevel = widget.popupHandler.sleepLevel + 200; // 수면 시간이 충분할 경우 증가
      }

      // sleepLevel 업데이트
      widget.popupHandler.updateStatus(
        newWaterLevel: widget.popupHandler.waterLevel,
        newMealLevel: widget.popupHandler.mealLevel,
        newSleepLevel: newSleepLevel,
      );

      // 서버에 저장할 SleepDto 데이터 생성
      String? username = await TokenService().getUsername();
      SleepDto newSleepRecord = SleepDto(
        date: formattedDate,
        sleep_time: '${_sleepTime!.hour}:${_sleepTime!.minute}:00',
        wake_up_time: '${_wakeUpTime!.hour}:${_wakeUpTime!.minute}:00',
        username: username ?? 'defaultUser',
      );

      try {
        // 기존 데이터 확인
        List<SleepDto> existingRecords = await sleepRepository.fetchSleepDataFromDatabase();

        // 동일한 날짜에 같은 수면 기록이 있는지 확인
        bool isDuplicate = existingRecords.any((record) =>
        record.date == formattedDate &&
            record.sleep_time == newSleepRecord.sleep_time &&
            record.wake_up_time == newSleepRecord.wake_up_time);

        if (!isDuplicate) {
          // 중복이 아니라면 데이터 저장
          await sleepRepository.saveSleepDataToDatabase([newSleepRecord]);
          print('Successfully saved sleep data to the server');
          await _loadSleepDataFromServer();
        } else {
          print('Duplicate sleep record exists. No data saved.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('중복된 수면 기록입니다. 다른 시간을 입력하세요.')),
          );
        }
      } catch (e) {
        print('Error sending data to the server: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수면 기록 저장 중 오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    } else {
      print('Sleep time or wake-up time is not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수면 시간을 선택해 주세요.')),
      );
    }
  }

  // 수면 그래프를 생성하고 스크롤 가능하도록 감싸는 메서드
  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('저장된 수면 기록이 없습니다.'));
    }

    List<BarChartGroupData> barGroups = _sleepRecords.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> record = entry.value;

      // 수면 및 기상 시간을 TimeOfDay로 변환
      TimeOfDay sleepTime = TimeOfDay(
        hour: int.parse(record['sleep_time']!.split(":")[0]),
        minute: int.parse(record['sleep_time']!.split(":")[1]),
      );
      TimeOfDay wakeUpTime = TimeOfDay(
        hour: int.parse(record['wake_up_time']!.split(":")[0]),
        minute: int.parse(record['wake_up_time']!.split(":")[1]),
      );

      // 수면 시간 계산
      Duration sleepDuration = _calculateSleepDuration(sleepTime, wakeUpTime);
      double sleepHours = sleepDuration.inMinutes / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sleepHours,
            color: const Color.fromARGB(255, 102, 68, 255),
            width: 20,
          ),
        ],
      );
    }).toList();

    // 권장 수면 시간 (예: 8시간)
    double recommendedSleepHours = 8.0;

    return makeScrollable(BarChart(
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
    ));
  }

  // 스크롤 가능하게 만드는 유틸리티 메서드
  Widget makeScrollable(Widget widget) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: widget,
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
        // sleepLevel이 증가했는지 확인
        if (widget.popupHandler.sleepLevel > _currentSleepLevel) {
          widget.popupHandler.triggerAnimation('sleeping', delayMilliseconds: 1000);
          print('Triggering sleeping animation for sleep level: ${widget.popupHandler.sleepLevel}');
        } else {
          print("No significant sleep level change, no animation triggered.");
        }

        // 뒤로 가기 허용
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => _selectSleepTime(context),
                  child: Text(_sleepTime == null
                      ? '취침 시간 선택'
                      : '취침 시간: ${_sleepTime!.hour}시 ${_sleepTime!.minute}분'),
                ),
                ElevatedButton(
                  onPressed: () => _selectWakeUpTime(context),
                  child: Text(_wakeUpTime == null
                      ? '기상 시간 선택'
                      : '기상 시간: ${_wakeUpTime!.hour}시 ${_wakeUpTime!.minute}분'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveSleepDataToServer,
                  child: const Text('저장하기'),
                ),
                const SizedBox(height: 24.0),
                const Text(
                  '수면 기록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
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
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sleepTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _sleepTime) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }

  Future<void> _selectWakeUpTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }
}
