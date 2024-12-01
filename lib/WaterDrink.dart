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
  int _currentWaterLevel = 0;
  Map<String, int> _dailyWaterIntake = {};
  static const int recommendedIntake = 750; // 권장 섭취량 기준

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _currentWaterLevel = widget.popupHandler.waterLevel;
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

  void _checkStatus() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int currentHour = DateTime.now().hour;
    int todayWaterIntake = _dailyWaterIntake[today] ?? 0;

    // 오전 6시 이전에는 PopupHandler 상태를 업데이트하지 않음
    if (currentHour < 6) {
      print("PopupHandler status not updated before 6:00 AM.");
      return;
    }
    widget.popupHandler.updateStatus(
      newWaterLevel: todayWaterIntake,
      newMealLevel: widget.popupHandler.mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel,
    );
  }

  List<BarChartGroupData> _generateBarChartData() {
    List<String> dates = _dailyWaterIntake.keys.toList()..sort();

    List<String> visibleDates =
        dates.length > 7 ? dates.sublist(dates.length - 7) : dates;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < visibleDates.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (_dailyWaterIntake[visibleDates[i]] ?? 0).toDouble(),
              width: 15,
              color: (_dailyWaterIntake[visibleDates[i]] ?? 0) >= recommendedIntake
                  ? Colors.green
                  : Colors.blue, // 권장 섭취량 초과 여부에 따라 색상 변경
            )
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width >= 600;

    // 그래프 너비 동적으로 설정
    double graphWidth = isWeb
        ? MediaQuery.of(context).size.width - 100 // 데스크톱: 화면 너비 기반
        : 7 * 80.0; // 모바일: 7개의 데이터 고정

    return WillPopScope(
      onWillPop: () async {
        if (widget.popupHandler.waterLevel > _currentWaterLevel) {
          widget.popupHandler.triggerAnimation(
              'drinkwater', delayMilliseconds: 1000);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("수분 섭취"),
          backgroundColor: const Color(0xFFFFF9C4),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("물 마시는 법"),
                    content: const Text(
                      "식사 전후 30분에서 1시간 사이에 물을 마시는 것이 좋습니다. "
                      "한 번에 많은 양의 물을 마시면 전해질 불균형이 생길 수 있으니, "
                      "한 잔씩 나누어 섭취하세요. 노년층은 매시간 의식적으로 물을 섭취하는 것이 중요합니다.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("닫기"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "연령별 권장 수분 섭취량 (mL/일):\n"
                "• 19-29세: 남성 981mL, 여성 709mL\n"
                "• 30-49세: 남성 957mL, 여성 772mL\n"
                "• 50-64세: 남성 940mL, 여성 784mL\n"
                "• 65-74세: 남성 904mL, 여성 624mL",
                style: TextStyle(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: graphWidth, // 동적으로 설정된 그래프 너비
                    child: BarChart(
                      BarChartData(
                        barGroups: _generateBarChartData(),
                        maxY: recommendedIntake.toDouble() + 1000, // 권장 섭취량을 기준으로 최대값 설정
                        backgroundColor: Colors.lightBlue[50],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                List<String> dates =
                                    _dailyWaterIntake.keys.toList()..sort();
                                List<String> visibleDates = dates.length > 7
                                    ? dates.sublist(dates.length - 7)
                                    : dates;
                                int index = value.toInt();
                                if (index >= 0 && index < visibleDates.length) {
                                  return Text(visibleDates[index],
                                      style: const TextStyle(fontSize: 10));
                                } else {
                                  return const Text("");
                                }
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 500, // 500ml 간격으로 표시
                              getTitlesWidget: (value, meta) =>
                                  Text('${value.toInt()}ml'),
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 500, // 500ml 간격으로 그리드 표시
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
                              y: recommendedIntake.toDouble(),
                              color: Colors.red,
                              strokeWidth: 2,
                              dashArray: [5, 5],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topLeft,
                                labelResolver: (line) =>
                                    '권장 섭취량: ${recommendedIntake}ml',
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF9C4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => _addWater(200),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF9C4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('+물 한 잔'),
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
