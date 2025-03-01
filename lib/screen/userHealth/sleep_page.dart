import 'package:flutter/material.dart';
import 'package:gungangazi/screen/character/character_status.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../../../dto/userHealth/sleep_dto.dart';
import '../../../repositories/userHealth/sleep_repository.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../character/popup_handler.dart';
import 'package:provider/provider.dart'; // ✅ Provider 추가

class SleepPage extends StatefulWidget {
  final PopupHandler popupHandler;
  final CharacterStatus characterStatus;
  

  const SleepPage({Key? key, required this.popupHandler, required this.characterStatus}) : super(key: key);

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
    _loadCharacterStatus(); // ✅ 비동기 상태 불러오기
    
  }

   Future<void> _loadCharacterStatus() async {
    final characterStatus = context.read<CharacterStatus>(); // ✅ Provider에서 가져오기
    await characterStatus.loadStatus(context);
    setState(() {
      _currentSleepLevel = characterStatus.sleep_level;
    });
  }

  // 서버에서 수면 데이터 가져오기
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
    print('_sleepRecords: $_sleepRecords'); // 디버깅용 출력
  }

  // 수면 데이터 서버에 저장하기
  Future<void> _saveSleepDataToServer() async {
    final characterStatus = Provider.of<CharacterStatus>(context, listen: false); // ✅ 안전하게 가져오기
    if (_sleepTime != null && _wakeUpTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Duration sleepDuration = _calculateSleepDuration(_sleepTime!, _wakeUpTime!);
      double sleepHours = sleepDuration.inMinutes / 60.0;

      // 새로운 sleepLevel 계산
      int newSleepLevel = characterStatus.sleep_level;
      if (sleepHours >= 5.0) {
        newSleepLevel += 200; // ✅ 5시간 이상 수면 시 증가
      }

      await characterStatus.updateStatus(
        newWaterLevel: characterStatus.water_level,
        newMealLevel: characterStatus.meal_level,
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
            color: const Color.fromARGB(255, 102, 68, 255),
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
    final characterStatus = context.read<CharacterStatus>(); // ✅ 
    return PopScope(
    canPop: true,
    onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
        if (characterStatus.sleep_level > _currentSleepLevel) {
         await widget.popupHandler.triggerAnimation('sleeping', delayMilliseconds: 1000);
          print('Triggering sleeping animation for sleep level: ${widget.characterStatus.sleep_level}');
        } else {
          print("No significant sleep level change, no animation triggered.");
        }

        }
  },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('수면'),
          backgroundColor: const Color(0xFFFFF9C4),
          // 그래프 아이콘 추가 (actions 프로퍼티)
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                // TODO: 아이콘 클릭 시 동작을 정의하세요.
                // 예: 다른 페이지 이동, 다이얼로그 표시 등
                print("그래프 아이콘 클릭됨!");
              },
            ),
          ],
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 버튼들을 수평으로 정렬
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _selectSleepTime(context),
                      icon: const Icon(Icons.bedtime),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF9C4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      label: Text(
                        _sleepTime == null
                            ? '취침 시각 선택'
                            : 'Sleep Time: ${_sleepTime!.format(context)}',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectWakeUpTime(context),
                      icon: const Icon(Icons.wb_sunny),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF9C4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      label: Text(
                        _wakeUpTime == null
                            ? '기상 시각 선택'
                            : 'Wake-up Time: ${_wakeUpTime!.format(context)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 저장 버튼
                ElevatedButton(
                  onPressed: _saveSleepDataToServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF9C4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('저장'),
                ),
                const SizedBox(height: 20),
                // 그래프를 표시
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
