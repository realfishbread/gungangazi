import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    sleepRepository = SleepRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _loadAllSleepDataFromServer();
    _currentSleepLevel = widget.popupHandler.sleepLevel;
  }

  // 서버에서 수면 데이터 가져오기
  Future<void> _loadAllSleepDataFromServer() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<SleepDto> serverData = await sleepRepository.fetchSleepDataFromDatabase();
      setState(() {
        _sleepRecords = serverData.map((dto) => {
              'date': dto.date,
              'sleep_time': dto.sleep_time,
              'wake_up_time': dto.wake_up_time,
              'username': dto.username,
            }).toList();

        // 날짜순 정렬 (최신 데이터가 위로 오도록)
        _sleepRecords.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']!);
          DateTime dateB = DateTime.parse(b['date']!);
          return dateB.compareTo(dateA); // 내림차순 정렬
        });
      });
    } catch (e) {
      print('Error loading sleep data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 그래프 생성 메서드
  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('저장된 수면 기록이 없습니다.'));
    }

    // 최근 7개의 수면 기록만 사용
    List<Map<String, String>> recentSleepRecords = _sleepRecords.length > 7
        ? _sleepRecords.sublist(_sleepRecords.length - 7)
        : _sleepRecords;

    List<BarChartGroupData> barGroups = recentSleepRecords.asMap().entries.map((entry) {
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
            color: const Color.fromARGB(255, 168, 148, 255),
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
        gridData: FlGridData(
          show: false, // 배경 모눈 제거
        ),
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
                if (index >= 0 && index < recentSleepRecords.length) {
                  return Text(recentSleepRecords[index]['date'] ?? '');
                } else {
                  return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 12,
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
                labelResolver: (line) => '권장: 8h',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 수면 시간 계산 메서드
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
        if (widget.popupHandler.sleepLevel > _currentSleepLevel) {
          widget.popupHandler.triggerAnimation('sleeping', delayMilliseconds: 1000);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('수면'),
          backgroundColor: const Color(0xFFFFF9C4),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '최근 수면 그래프',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 300,
                          child: _buildSleepGraph(), // 차트 추가
                        ),
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '수면 기록',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _sleepRecords.length,
                          itemBuilder: (context, index) {
                            final record = _sleepRecords[index];
                            return ListTile(
                              title: Text(record['date'] ?? ''),
                              subtitle: Text(
                                "취침: ${record['sleep_time']} | 기상: ${record['wake_up_time']}",
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


  