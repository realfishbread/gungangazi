import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../repositories/userHealth/water_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart'; // PopupHandler 임포트

class WaterDrink extends StatefulWidget {
  final PopupHandler popupHandler; // PopupHandler 인스턴스를 받도록 설정

  const WaterDrink({Key? key, required this.popupHandler}) : super(key: key);

  @override
  _WaterDrinkState createState() => _WaterDrinkState();
}

class _WaterDrinkState extends State<WaterDrink> {
   
  final WaterRepository waterRepository = WaterRepository(
    dioService: DioService(),
    tokenService: TokenService(),
  );
  int _currentWaterLevel = 0; //
  Map<String, int> _dailyWaterIntake = {};

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _currentWaterLevel = widget.popupHandler.sleepLevel;
  }

  Future<void> _loadWaterIntake() async {
    _dailyWaterIntake = await waterRepository.fetchWaterIntake();
    setState(() {});
    _checkStatus(); // 초기 로딩 시에도 수분 상태와 식사 상태 확인
  }

  void _addWater(int amount) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _dailyWaterIntake[today] = (_dailyWaterIntake[today] ?? 0) + amount;
      if (_dailyWaterIntake[today]! < 0) {
        _dailyWaterIntake[today] = 0;
      }
    });
    waterRepository.saveWaterIntake(_dailyWaterIntake);
    _checkStatus(); // 물 섭취량 확인 후 상태 업데이트
  }

  // 수분 및 식사 상태 확인
  void _checkStatus() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int todayWaterIntake = _dailyWaterIntake[today] ?? 0;
    int todayMealLevel = widget.popupHandler.mealLevel; // 현재 mealLevel 가져오기

    

    // WaterDrink의 _addWater 메서드에 상태 업데이트
  widget.popupHandler.updateStatus(
    newWaterLevel: todayWaterIntake,
    newMealLevel: todayMealLevel,
    newSleepLevel: widget.popupHandler.sleepLevel
  );
  print("Water added and PopupHandler status updated - Water Level: $todayWaterIntake");

    if (todayWaterIntake <= 200) {
      _showWarning('물');
    }
  }

  void _showWarning(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고!'),
          content: Text('오늘 $type을 너무 적게 섭취했어요! 더 많이 섭취해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarChartData() {
    List<String> dates = _dailyWaterIntake.keys.toList()..sort();
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < dates.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (_dailyWaterIntake[dates[i]] ?? 0).toDouble(),
              width: 15,
              color: Colors.blue,
            )
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // 물 상태가 증가했는지 확인하고 애니메이션 실행
      if (widget.popupHandler.waterLevel > _currentWaterLevel ) {
        widget.popupHandler.triggerAnimation('drinkwater', delayMilliseconds: 1000);
      } else {
        print("No significant water level change, no animation triggered.");
      }

      // 뒤로가기 동작 허용
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("수분 섭취"),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: _generateBarChartData(),
                  backgroundColor: Colors.lightBlue[50],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          List<String> dates = _dailyWaterIntake.keys.toList()..sort();
                          return Text(dates[value.toInt()], style: const TextStyle(fontSize: 10));
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 200,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}ml'),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 2000, // 권장 수분 섭취량 (예: 2000ml)
                        color: Colors.red,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topLeft,
                          labelResolver: (line) => '권장 섭취량: 2000ml',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _addWater(-200),
                      child: const Text('-물 한 잔 취소'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _addWater(200),
                      child: const Text('+물 한 잔 200ml'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

