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
      }).toList();
    });
    print('_sleepRecords: $_sleepRecords'); // Debugging print
  }

  // Save sleep data locally and send it to the server
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
          print('Error loading saved data: $e');
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
      print('Successfully saved sleep data locally: $records');

      // Send saved local data to server
      await _saveSleepDataToDatabase();
      // Reload latest data from server for graph
      await _loadSleepDataFromServer();
    } else {
      print('Sleep time or wake-up time is not selected');
    }
  }

  // Send local data to the server
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
            username: 'exampleUser', // Replace with actual username
          );
        }).toList();

        await sleepRepository.saveSleepDataToDatabase(records);
      } catch (e) {
        print('Error sending data to the server: $e');
      }
    } else {
      print('No sleep data saved locally.');
    }
  }

  // Build sleep records graph
  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('No saved sleep records.'));
    }

    List<BarChartGroupData> barGroups = _sleepRecords.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> record = entry.value;

      // Convert sleep and wake-up times to TimeOfDay
      TimeOfDay sleepTime = TimeOfDay(
        hour: int.parse(record['sleepTime']!.split(":")[0]),
        minute: int.parse(record['sleepTime']!.split(":")[1]),
      );
      TimeOfDay wakeUpTime = TimeOfDay(
        hour: int.parse(record['wakeUpTime']!.split(":")[0]),
        minute: int.parse(record['wakeUpTime']!.split(":")[1]),
      );

      // Calculate sleep duration
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
    return Scaffold(
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
                onPressed: _saveSleepDataLocally,
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
