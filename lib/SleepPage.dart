import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../dto/userHealth/sleep_dto.dart';
import '../repositories/userHealth/sleep_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SleepPage extends StatefulWidget {
  final PopupHandler popupHandler;

  const SleepPage({Key? key, required this.popupHandler}) : super(key: key);

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  List<Map<String, String>> _sleepRecords = [];
  late final SleepRepository sleepRepository;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sleepRepository = SleepRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _loadAllSleepDataFromServer();
  }

  Future<void> _loadAllSleepDataFromServer() async {
    try {
      List<SleepDto> serverData = await sleepRepository.fetchSleepDataFromDatabase();
      setState(() {
        _sleepRecords = serverData.map((dto) => {
              'date': dto.date,
              'sleep_time': dto.sleep_time,
              'wake_up_time': dto.wake_up_time,
              'username': dto.username,
            }).toList();

        // 날짜순 정렬 (최신 데이터가 오른쪽으로 표시되도록 오름차순)
        _sleepRecords.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']!);
          DateTime dateB = DateTime.parse(b['date']!);
          return dateA.compareTo(dateB);
        });
      });
    } catch (e) {
      print('Error loading sleep data: $e');
    }
  }

  // 그래프 생성 메서드
  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('저장된 수면 기록이 없습니다.'));
    }

    List<Map<String, String>> limitedSleepRecords = _sleepRecords.length > 10
        ? _sleepRecords.sublist(_sleepRecords.length - 10)
        : _sleepRecords;

    List<BarChartGroupData> barGroups = limitedSleepRecords.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> record = entry.value;

      TimeOfDay sleepTime = TimeOfDay(
        hour: int.parse(record['sleep_time']!.split(":")[0]),
        minute: int.parse(record['sleep_time']!.split(":")[1]),
      );
      TimeOfDay wakeUpTime = TimeOfDay(
        hour: int.parse(record['wake_up_time']!.split(":")[0]),
        minute: int.parse(record['wake_up_time']!.split(":")[1]),
      );

      Duration sleepDuration = _calculateSleepDuration(sleepTime, wakeUpTime);
      double sleepHours = sleepDuration.inMinutes / 60.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sleepHours,
            color: const Color.fromARGB(255, 168, 148, 255),
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
              interval: 2,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}h'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < _sleepRecords.length) {
                  return Text(_sleepRecords[index]['date'] ?? '');
                } else {
                  return const Text('');
                }
              },
            ),
          ),
        ),
        minY: 0,
        maxY: 12,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    if (isWeb) {
      // 웹에서는 그래프만 표시
      return Scaffold(
        appBar: AppBar(
          title: const Text('수면 그래프'),
          backgroundColor: const Color(0xFFFFF9C4),
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: _sleepRecords.length * 80.0,
                maxWidth: _sleepRecords.length * 80.0,
              ),
              child: _buildSleepGraph(),
            ),
          ),
        ),
      );
    } else {
      // 모바일에서는 기존 UI 유지
      return Scaffold(
        appBar: AppBar(
          title: const Text('수면'),
          backgroundColor: const Color(0xFFFFF9C4),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '최근 수면 그래프',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _sleepRecords.length * 80.0,
                    maxWidth: _sleepRecords.length * 80.0,
                  ),
                  child: _buildSleepGraph(),
                ),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '수면 기록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: _sleepRecords.length,
                itemBuilder: (context, index) {
                  final record = _sleepRecords[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        record['date'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "취침: ${record['sleep_time']} | 기상: ${record['wake_up_time']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}



