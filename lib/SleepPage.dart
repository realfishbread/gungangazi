import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../dto/userHealth/sleep_dto.dart';
import '../repositories/userHealth/sleep_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // ScrollController 추가
  final ScrollController _scrollController = ScrollController();

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

        // 날짜순 정렬 (최신 데이터가 오른쪽으로 표시되도록 오름차순)
        _sleepRecords.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']!);
          DateTime dateB = DateTime.parse(b['date']!);
          return dateA.compareTo(dateB);
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

  // 수면 데이터 서버에 저장하기
  Future<void> _saveSleepDataToServer() async {
    if (_sleepTime == null || _wakeUpTime == null) {
      _showSnackBar('수면 시간을 선택해 주세요.');
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Duration sleepDuration = _calculateSleepDuration(_sleepTime!, _wakeUpTime!);
    double sleepHours = sleepDuration.inMinutes / 60.0;

    // 새로운 sleepLevel 계산
    int newSleepLevel = _currentSleepLevel;
    if (sleepHours >= 5.0) {
      newSleepLevel += 200; // 충분한 수면 시간일 경우 증가
    }

    widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: widget.popupHandler.mealLevel,
      newSleepLevel: newSleepLevel,
    );

    String? username = await TokenService().getUsername();
    if (username == null) {
      _showSnackBar('사용자 정보를 가져올 수 없습니다.');
      return;
    }

    SleepDto newSleepRecord = SleepDto(
      date: formattedDate,
      sleep_time: '${_sleepTime!.hour}:${_sleepTime!.minute}:00',
      wake_up_time: '${_wakeUpTime!.hour}:${_wakeUpTime!.minute}:00',
      username: username,
    );

    try {
      // 중복 데이터 확인
      bool isDuplicate = _sleepRecords.any((record) =>
          record['date'] == formattedDate &&
          record['sleep_time'] == newSleepRecord.sleep_time &&
          record['wake_up_time'] == newSleepRecord.wake_up_time);

      if (!isDuplicate) {
        await sleepRepository.saveSleepDataToDatabase([newSleepRecord]);
        print('Successfully saved sleep data to the server');
        await _loadAllSleepDataFromServer();
      } else {
        _showSnackBar('중복된 수면 기록입니다.');
      }
    } catch (e) {
      print('Error sending data to the server: $e');
      _showSnackBar('수면 기록 저장 중 오류가 발생했습니다.');
    }
  }

  // 그래프 생성 메서드
  Widget _buildSleepGraph() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('저장된 수면 기록이 없습니다.'));
    }

    // Bar Chart 데이터 생성
    // 최근 10개의 수면 데이터를 가져오기
List<Map<String, String>> limitedSleepRecords = _sleepRecords.length > 10
    ? _sleepRecords.sublist(_sleepRecords.length - 10)
    : _sleepRecords;

    // BarChart에 전달할 데이터 수정
    List<BarChartGroupData> barGroups = limitedSleepRecords.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> record = entry.value;

      // 수면 시간 계산 로직 동일
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

    double recommendedSleepHours = 8.0; // 권장 수면 시간

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        gridData: FlGridData(show: false),
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

  // 취침 시간 선택 메서드
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

// 기상 시간 선택 메서드
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSleepGraphContainer(bool isWeb) {
    double graphWidth = isWeb
        ? _sleepRecords.length * 80.0 // 웹: 데이터 수에 따라 동적 너비
        : MediaQuery.of(context).size.width; // 모바일: 화면 너비 고정

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ImprovedScrolling(
        scrollController: _scrollController,
        enableMMBScrolling: true,
        enableKeyboardScrolling: true,
        enableCustomMouseWheelScrolling: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: graphWidth,
              maxWidth: graphWidth,
            ),
            child: _buildSleepGraph(),
          ),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final bool isWeb = kIsWeb;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _selectSleepTime(context),
                icon: const Icon(Icons.bed),
                label: Text(
                  _sleepTime == null
                      ? '취침 시각 선택'
                      : '취침: ${_sleepTime!.format(context)}',
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _selectWakeUpTime(context),
                icon: const Icon(Icons.wb_sunny),
                label: Text(
                  _wakeUpTime == null
                      ? '기상 시각 선택'
                      : '기상: ${_wakeUpTime!.format(context)}',
                ),
              ),
              ElevatedButton(
                onPressed: _saveSleepDataToServer,
                child: const Text('저장'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '최근 수면 그래프',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2, // 그래프가 차지하는 비율
            child: _buildSleepGraphContainer(isWeb),
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
            flex: 1, // 수면 기록 리스트 비율
            child: ListView.builder(
              itemCount: _sleepRecords.length,
              itemBuilder: (context, index) {
                final record = _sleepRecords[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    ),
  );
}
}


