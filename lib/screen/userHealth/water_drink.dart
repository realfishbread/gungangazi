import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../repositories/userHealth/water_repository.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../../repositories/auth/profile_repository.dart';
import '../character/popup_handler.dart'; // PopupHandler 임포트
import 'package:gungangazi/screen/character/character_status.dart';

class WaterDrink extends StatefulWidget {
  final PopupHandler popupHandler; // PopupHandler 인스턴스를 받도록 설정
  final CharacterStatus characterStatus; // ✅ 추가

  const WaterDrink({Key? key, required this.popupHandler, required this.characterStatus}) : super(key: key);

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
  int recommendedIntake = 750; // 권장 섭취량 기준
  final DioService dioService = DioService();
  late ProfileRepository profileRepository;
  int? userAge = 0;
  String userGender = "남성";

 
  @override
  void initState() {
    super.initState();
    profileRepository = ProfileRepository(dioService: DioService(), tokenService: TokenService(),);
    _loadUserInfo();
    _loadWaterIntake();
    _currentWaterLevel = widget.characterStatus.waterLevel;
  }

   Future<void> _loadUserInfo() async {
  try {
    final userInfo = await dioService.getUserInfo(); // 사용자 정보 가져오기
    if (userInfo != null) {
      setState(() {
        // 나이: 숫자만 추출
        userAge = int.tryParse(userInfo['age']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;

        // 성별: 값이 없거나 예상 범위를 벗어날 경우 기본값 설정
        userGender = (userInfo['gender'] == '남성' || userInfo['gender'] == '여성') 
          ? userInfo['gender'] 
          : '남성'; // 기본값: '남성'

        // 권장 칼로리 계산
        if (userAge != null && userGender != null) {
          recommendedIntake = _calculateRecommendedIntake(userAge!, userGender!);
        }
      });
    }
  } catch (e) {
    print("Failed to load user info: $e");
  }
}

  int _calculateRecommendedIntake(int age, String gender) {
    if (gender == "남성") {
      if (age >= 6 && age <= 8) return 589;
      if (age >= 9 && age <= 11) return 686;
      if (age >= 12 && age <= 14) return 911;
      if (age >= 15 && age <= 18) return 920;
      if (age >= 19 && age <= 29) return 981;
      if (age >= 30 && age <= 49) return 957;
      if (age >= 50 && age <= 64) return 940;
      if (age >= 65 && age <= 74) return 904;
      return 662; // 75세 이상
    } else if (gender == "여성") {
      if (age >= 6 && age <= 8) return 514;
      if (age >= 9 && age <= 11) return 643;
      if (age >= 12 && age <= 14) return 610;
      if (age >= 15 && age <= 18) return 659;
      if (age >= 19 && age <= 29) return 709;
      if (age >= 30 && age <= 49) return 772;
      if (age >= 50 && age <= 64) return 784;
      if (age >= 65 && age <= 74) return 624;
      return 552; // 75세 이상
    }
    return 750; // 기본값
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

  Future<void> _checkStatus() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int currentHour = DateTime.now().hour;
    int todayWaterIntake = _dailyWaterIntake[today] ?? 0;

    // 오전 6시 이전에는 PopupHandler 상태를 업데이트하지 않음
    
    await widget.popupHandler.updateStatus(
      newWaterLevel: todayWaterIntake,
      newMealLevel: widget.popupHandler.mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel,
    );
     // ✅ UI 갱신
    setState(() {});
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
          await widget.popupHandler.triggerAnimation('drinkwater', delayMilliseconds: 1000);
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
                    title: const Text("수분 섭취 가이드"),
                    content: const Text(
                      "연령별 권장 수분 섭취량 (mL/일):\n"
                      "• 19-29세: 남성 981mL, 여성 709mL\n"
                      "• 30-49세: 남성 957mL, 여성 772mL\n"
                      "• 50-64세: 남성 940mL, 여성 784mL\n"
                      "• 65-74세: 남성 904mL, 여성 624mL\n\n"
                      "물은 식사 전후 30분에서 1시간 사이에 마시는 것이 좋습니다. "
                      "한 번에 많은 양의 물을 마시면 전해질 불균형이 생길 수 있으니, 한 잔씩 나누어 섭취하세요. "
                      "노년층은 매시간 의식적으로 물을 섭취하는 것이 중요합니다.",
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _addWater(200), // 물 섭취 추가
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_drink, // 물컵 아이콘
                          color: Colors.blueAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '+물 한 잔',
                          style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40), // 간격 조정
                  GestureDetector(
                    onTap: () => _addWater(-200), // 물 섭취 취소
                    child: Column(
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '취소',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14),
                        ),
                      ],
                    ),
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
