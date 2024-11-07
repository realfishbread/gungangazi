import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../repositories/userHealth/water_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';

class WaterDrink extends StatefulWidget {
  const WaterDrink({super.key});

  @override
  _WaterDrinkState createState() => _WaterDrinkState();
}

class _WaterDrinkState extends State<WaterDrink> {
  final WaterRepository waterRepository = WaterRepository(
    dioService: DioService(),
    tokenService: TokenService(), // TokenService 추가
  );

  Map<String, int> _dailyWaterIntake = {};

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
  }

  Future<void> _loadWaterIntake() async {
    _dailyWaterIntake = await waterRepository.fetchWaterIntake();
    setState(() {});
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
    return Scaffold(
      appBar: AppBar(
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
                      child: const Text('-200ml'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _addWater(200),
                      child: const Text('+200ml'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _addWater(-500),
                      child: const Text('-500ml'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _addWater(500),
                      child: const Text('+500ml'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
