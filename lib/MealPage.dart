import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../dto/userHealth/meal_dto.dart';
import '../../repositories/userHealth/meal_repository.dart';
import '../../services/dio_service.dart';
import '../../services/TokenService.dart';
import 'PopupHandler.dart';

class MealPage extends StatefulWidget {
  final PopupHandler popupHandler;

  const MealPage({Key? key, required this.popupHandler}) : super(key: key);

  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final Map<String, List<String>> _mealsByDate = {};
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  late MealRepository _mealRepository;
  int _mealLevel = 0; // 초기 mealLevel 설정
  String _selectedMealType = "식사"; // 기본 식사 타입 선택

  @override
  void initState() {
    super.initState();
    _mealRepository = MealRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _fetchMeals();
  }

  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // 서버에서 모든 식사 기록 가져오기
  void _fetchMeals() async {
    try {
      List<MealDTO> meals = await _mealRepository.fetchAllMeals(); // 모든 날짜의 기록 가져오기
      setState(() {
        for (var meal in meals) {
          if (_mealsByDate.containsKey(meal.date)) {
            _mealsByDate[meal.date]?.add(meal.meal);
          } else {
            _mealsByDate[meal.date] = [meal.meal];
          }
        }

        // 현재 날짜 기준으로 mealLevel 계산
        _mealLevel = (_mealsByDate[_getFormattedDate()]?.length ?? 0) * 200;
      });
    } catch (e) {
      print('Error loading meals: $e');
    }
  }

  // PopupHandler 상태 업데이트
  void _updatePopupHandler() {
    widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: _mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel,
    );
    print("Meal Level updated: $_mealLevel");
  }

  void _addMeal() async {
    final String meal = _mealController.text.trim();
    final int? calories = int.tryParse(_caloriesController.text.trim());
    if (meal.isNotEmpty && calories != null) {
      final String currentDate = _getFormattedDate();
      String? username = await TokenService().getUsername();
      final MealDTO newMeal = MealDTO(
        id: null, // 수정: id를 nullable로 처리
        date: currentDate,
        meal: meal,
        username: username ?? '',
        calories: calories,
        mealType: _selectedMealType, // 식사/간식 구분 추가
      );

      try {
        await _mealRepository.addMeal(newMeal);
        setState(() {
          String mealEntry = '$_selectedMealType - $meal ($calories kcal)';
          if (_mealsByDate.containsKey(currentDate)) {
            _mealsByDate[currentDate]?.add(mealEntry);
          } else {
            _mealsByDate[currentDate] = [mealEntry];
          }

          // 현재 날짜 기준 식사 개수를 기반으로 mealLevel 계산
          _mealLevel = (_mealsByDate[currentDate]?.length ?? 0) * 200;

          _mealController.clear();
          _caloriesController.clear();
        });

        // 다마고치 상태 업데이트 및 로그 추가
        widget.popupHandler.updateStatus(
          newWaterLevel: widget.popupHandler.waterLevel,
          newMealLevel: _mealLevel,
          newSleepLevel: widget.popupHandler.sleepLevel,
        );

        _updatePopupHandler();
        print("Meal added and PopupHandler status updated - Meal Level: $_mealLevel");
      } catch (e) {
        print('Error adding meal: $e');
      }
    }
  }

 Future<void> _deleteMeal(String date, int index) async {
    try {
      // 서버로 삭제 요청 (mealId를 서버에서 제공받아야 함)
      final mealId = "meal-id"; // 서버에서 받은 meal ID 사용
      await _mealRepository.deleteMeal(mealId);

      // UI에서 기록 삭제
      setState(() {
        _mealsByDate[date]?.removeAt(index);
        if (_mealsByDate[date]?.isEmpty ?? true) {
          _mealsByDate.remove(date);
        }

        // mealLevel 업데이트
        _mealLevel = (_mealsByDate[_getFormattedDate()]?.length ?? 0) * 200;
      });

      // PopupHandler 상태 업데이트
      _updatePopupHandler();

      print("Meal deleted and PopupHandler status updated - Meal Level: $_mealLevel");
    } catch (e) {
      print('Error deleting meal: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // 조건에 따라 애니메이션 실행
      if (widget.popupHandler.mealLevel > widget.popupHandler.mealLevelThreshold) {
        widget.popupHandler.triggerAnimation('eatingmeal', delayMilliseconds: 1000);
      } else {
        print("No significant meal level change, no animation triggered.");
      }
      // 뒤로 가기 허용
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('날짜별 식단 기록'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButton<String>(
                    value: _selectedMealType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMealType = newValue!;
                      });
                    },
                    items: <String>['식사', '간식']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _mealController,
                    decoration: const InputDecoration(
                      labelText: '식사/간식 내용 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: '칼로리 입력 (kcal)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addMeal,
              child: const Text('기록 추가'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _mealsByDate.isEmpty
                  ? const Center(
                      child: Text('기록된 식사가 없습니다.'),
                    )
                  : ListView(
                      children: _mealsByDate.keys.map((date) {
                        return ExpansionTile(
                          title: Text(date),
                          children: _mealsByDate[date]!
                              .asMap()
                              .entries
                              .map((entry) {
                                final int index = entry.key;
                                final String meal = entry.value;

                                return ListTile(
                                  title: Text(meal),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      _deleteMeal(date, index); // 삭제 메서드 호출
                                    },
                                  ),
                                );
                              }).toList(),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
}