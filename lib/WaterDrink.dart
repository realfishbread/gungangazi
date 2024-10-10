import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterDrink extends StatefulWidget {
  const WaterDrink({super.key});

  @override
  _WaterDrinkState createState() => _WaterDrinkState();
}

class _WaterDrinkState extends State<WaterDrink> {
  Map<String, int> _dailyWaterIntake = {};

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
  }

  // 저장된 일별 물 섭취량 불러오기
  _loadWaterIntake() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyWaterIntake = Map<String, int>.from(
          (prefs.getStringList('waterIntakeList') ?? []).asMap().map(
                (index, value) =>
                MapEntry(value.split('|')[0], int.parse(value.split('|')[1])),
          ));
    });
  }

  // 물 섭취량 저장
  _saveWaterIntake() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'waterIntakeList',
        _dailyWaterIntake.entries
            .map((entry) => '${entry.key}|${entry.value}')
            .toList());
  }

  // 오늘 날짜의 물 섭취량 업데이트
  void _addWater(int amount) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _dailyWaterIntake[today] = (_dailyWaterIntake[today] ?? 0) + amount;
      if (_dailyWaterIntake[today]! < 0) {
        _dailyWaterIntake[today] = 0; // 음수가 되지 않도록 처리
      }
    });
    _saveWaterIntake();
  }

  // 막대 그래프에 사용할 데이터를 생성
  List<BarChartGroupData> _generateBarChartData() {
    List<String> dates = _dailyWaterIntake.keys.toList()..sort();
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < dates.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (_dailyWaterIntake[dates[i]] ?? 0).toDouble(), // null인 경우 0 처리
              width: 15,
              color: Colors.blue, // 막대 색상
            )
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WaterDrink"),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // 웹과 앱을 구분하는 기준 (예: 600dp 이상은 웹)
          double chartHeight = isWeb ? constraints.maxHeight * 0.5 : constraints.maxHeight * 0.4;
          double chartPadding = isWeb ? 50 : 16;

          return Column(
            children: [
              // 막대 그래프
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(chartPadding),
                  child: SizedBox(
                    height: chartHeight,
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
                                return Text(
                                  dates[value.toInt()],
                                  style: TextStyle(fontSize: isWeb ? 12 : 10),
                                );
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 200, // 가로선 간격을 200으로 설정
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}ml');
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false, // 세로선을 숨김
                          horizontalInterval: 200, // 가로선 간격을 200으로 설정
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!, // 가로선 색상
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: true),
                      ),
                    ),
                  ),
                ),
              ),
              // 물 섭취량 추가/차감 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 200ml 빼기 버튼
                        ElevatedButton(
                          onPressed: () => _addWater(-200), // 물 200ml 차감
                          child: const Text('-200ml'),
                        ),
                        const SizedBox(width: 20),
                        // 200ml 더하기 버튼
                        ElevatedButton(
                          onPressed: () => _addWater(200), // 물 200ml 추가
                          child: const Text('+200ml'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 500ml 빼기 버튼
                        ElevatedButton(
                          onPressed: () => _addWater(-500), // 물 500ml 차감
                          child: const Text('-500ml'),
                        ),
                        const SizedBox(width: 20),
                        // 500ml 더하기 버튼
                        ElevatedButton(
                          onPressed: () => _addWater(500), // 물 500ml 추가
                          child: const Text('+500ml'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
