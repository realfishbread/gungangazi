import 'MealPage.dart';
import 'SleepPage.dart';
import 'WaterDrink.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


// Main screen: SorhkPage
class SorhkPage extends StatefulWidget {
  @override
  _SorhkPageState createState() => _SorhkPageState();
}

class _SorhkPageState extends State<SorhkPage> {
  List<SleepData> sleepDataList = [];
  List<DietData> dietDataList = [];
  List<WaterData> waterDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchSleepData();
    _fetchDietData();
    _fetchWaterData();
  }

  // 각 데이터를 불러오는 메서드
  Future<void> _fetchSleepData() async {
    // TODO: Implement API fetch logic
  }

  Future<void> _fetchDietData() async {
    // TODO: Implement API fetch logic
  }

  Future<void> _fetchWaterData() async {
    // TODO: Implement API fetch logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Data Cards'),
      ),
      body: ListView(
        children: [
          SleepCard(dataList: sleepDataList),  // 수면 카드
          DietCard(dataList: dietDataList),    // 식단 카드
          WaterCard(dataList: waterDataList),  // 수분 카드
        ],
      ),
    );
  }
}

// SleepCard: 수면 데이터를 보여주는 위젯
class SleepCard extends StatelessWidget {
  final List<SleepData> dataList;

  SleepCard({required this.dataList});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SleepPage()));
      },
      child: Container(
        height: 300,  // 카드의 높이를 300으로 설정
        margin: EdgeInsets.all(10),
        child: Card(
          child: Column(
            children: [
              ListTile(
                title: Text('수면'),
                subtitle: Text('Hours slept each day this week'),
              ),
              Expanded(
                // 그래프가 남은 공간을 차지하도록 설정
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: BarChartWidget(dataList: dataList.map((e) => e.hours).toList()), // 그래프 위젯
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// DietCard: 식단 데이터를 보여주는 위젯
class DietCard extends StatelessWidget {
  final List<DietData> dataList;

  DietCard({required this.dataList});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MealPage()));
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('식단'),
              subtitle: Text('Meal descriptions'),
            ),
            dataList.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('No diet data available.'),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Meal: ${dataList[index].meal}'),
                  subtitle: Text('Description: ${dataList[index].description}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// WaterCard: 수분 데이터를 보여주는 위젯
class WaterCard extends StatelessWidget {
  final List<WaterData> dataList;

  WaterCard({required this.dataList});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => WaterDrink()));
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('수분'),
              subtitle: Text('Water intake for each day'),
            ),
            dataList.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('No water intake data available.'),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Day: ${dataList[index].day}'),
                  subtitle: Text('Liters: ${dataList[index].liters}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 공통 그래프 위젯: 데이터가 없을 경우 기본값 0, 있을 경우 해당 데이터로 그래프를 그립니다.
class BarChartWidget extends StatelessWidget {
  final List<double> dataList;

  BarChartWidget({required this.dataList});

  @override
  Widget build(BuildContext context) {
    // 데이터가 없으면 기본값 0으로 설정
    List<double> dataToShow = dataList.isNotEmpty
        ? dataList
        : List.generate(7, (index) => 0.0); // 데이터가 없으면 0으로 채운 리스트 생성

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14);
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = Text('Mon', style: style);
                    break;
                  case 1:
                    text = Text('Tue', style: style);
                    break;
                  case 2:
                    text = Text('Wed', style: style);
                    break;
                  case 3:
                    text = Text('Thu', style: style);
                    break;
                  case 4:
                    text = Text('Fri', style: style);
                    break;
                  case 5:
                    text = Text('Sat', style: style);
                    break;
                  case 6:
                    text = Text('Sun', style: style);
                    break;
                  default:
                    text = Text('', style: style);
                    break;
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
            ),
          ),
        ),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              toY: dataToShow.length > index ? dataToShow[index] : 0, // 데이터가 있으면 해당 값을, 없으면 0
              color: Colors.lightBlueAccent,
            ),
          ]);
        }),
      ),
    );
  }
}



// 데이터 모델 클래스
class SleepData {
  final String day;
  final double hours;
  SleepData({required this.day, required this.hours});
}

class DietData {
  final String meal;
  final String description;
  DietData({required this.meal, required this.description});
}

class WaterData {
  final String day;
  final double liters;
  WaterData({required this.day, required this.liters});
}
