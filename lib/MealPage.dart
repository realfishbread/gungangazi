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
  final Map<String, List<Map<String, dynamic>>> _mealsByDate = {}; // 수정: id 포함
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  late MealRepository _mealRepository;
  int _mealLevel = 0; // 초기 MealLevel 설정
  String _selectedMealType = "식사"; // 기본 식사 타입 선택
  bool _isLoading = true; // 로딩 상태 플래그
  int _currentMeal = 0;
  String? _gender;



  @override
  void initState() {
    super.initState();
    _fetchGender(); // 성별 가져오기
    _mealRepository = MealRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _fetchMeals().then((_) {
    setState(() {
      // Total calories를 가져오기 위해 현재 날짜로 상태 업데이트
      _calculateTotalCalories(_getFormattedDate());
    });
    });
    _currentMeal = widget.popupHandler.mealLevel;
  }


  Future<void> _fetchGender() async {
  try {
    // 예시: 서버에서 성별 데이터 가져오기
    String? gender = await DioService().getGender();
    print('Fetched gender: $gender');
    setState(() {
      _gender = gender; // 성별 저장
    });
  } catch (e) {
    print('Error fetching gender: $e');
  }
}

  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // **하루 총 칼로리와 권장 칼로리 비교를 위한 위젯 추가**
  Widget _buildCalorieSummary(String date) {
    final int totalCalories = _calculateTotalCalories(date);
    final int recommendedCalories = (_gender == '여성') ? 2000 : 2600; // 성별에 따른 권장 칼로리

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "오늘 총 칼로리 섭취: $totalCalories Kcal",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (totalCalories > recommendedCalories)
            Text(
              "초과된 칼로리: ${totalCalories - recommendedCalories} Kcal",
              style: const TextStyle(color: Colors.red, fontSize: 14),
            )
          else
            Text(
              "남은 칼로리: ${recommendedCalories - totalCalories} Kcal",
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
      ],
    ),
  );
}

  // 서버에서 모든 식사 기록 가져오기
  Future<void> _fetchMeals() async {
    try {
      print("Fetching meals from server...");
      List<MealDTO> meals = await _mealRepository.fetchAllMeals(); // 서버에서 데이터 가져오기
      print("Fetched meals: $meals");

      setState(() {
        _mealsByDate.clear(); // 기존 데이터 초기화
        for (var meal in meals) {
          final mealData = {
            'id': meal.id, // id 포함
            'meal': meal.meal,
            'calories': meal.calories,
            'meal_type': meal.meal_type,
          };

          if (_mealsByDate.containsKey(meal.date)) {
            _mealsByDate[meal.date]?.add(mealData);
          } else {
            _mealsByDate[meal.date] = [mealData];
          }
        }
        _mealLevel = ((_mealsByDate[_getFormattedDate()]?.length) ?? 0) * 200; // MealLevel 계산
        print("Updated MealLevel: $_mealLevel");
        _isLoading = false; // 로딩 완료
        _updatePopupHandler();
      });
    } catch (e) {
      print('Error loading meals: $e');
      setState(() {
        _isLoading = false; // 에러 발생 시 로딩 상태 해제
      });
    }
  }

  // PopupHandler 상태 업데이트
  void _updatePopupHandler() {
    print("Updating PopupHandler...");
    int currentHour = DateTime.now().hour;
    // 오전 6시 이전에는 PopupHandler 상태를 업데이트하지 않음
    if (currentHour < 6) {
      print("PopupHandler status not updated before 6:00 AM.");
      return;
    }
    widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: _mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel,
    );
    print("PopupHandler updated: Meal Level: $_mealLevel");
  }

  // 새로운 식사 추가
  void _addMeal() async {
    final String meal = _mealController.text.trim();
    final int? calories = int.tryParse(_caloriesController.text.trim());
    if (meal.isNotEmpty && calories != null) {
      final String currentDate = _getFormattedDate();
      String? username = await TokenService().getUsername();
      final MealDTO newMeal = MealDTO(
        id: '', // id는 서버에서 생성
        date: currentDate,
        meal: meal,
        username: username ?? '',
        calories: calories,
        meal_type: _selectedMealType,
      );

      try {
        print("Adding new meal: ${newMeal.toJson()}");
        await _mealRepository.addMeal(newMeal);

        // 저장 후 데이터를 새로고침
        await _fetchMeals(); // 최신 데이터 가져오기
        setState(() {
          _mealController.clear();
          _caloriesController.clear();
        });

        _updatePopupHandler(); // 상태 업데이트
        print("Meal added successfully. Updated Meal Level: $_mealLevel");
      } catch (e) {
        print('Error adding meal: $e');
         await _fetchMeals(); // 최신 데이터 가져오기
        setState(() {
          _mealController.clear();
          _caloriesController.clear();
        });
      }
    } else {
      print("Invalid input: Meal or Calories is empty/invalid.");
    }
  }
    int _calculateTotalCalories(String date) {
  // 해당 날짜에 데이터가 없는 경우 0 반환
  if (!_mealsByDate.containsKey(date)) return 0;

  // 총 칼로리를 계산
  return _mealsByDate[date]!.fold<int>(
    0,
    (sum, meal) {
      // 'calories' 키가 존재하고 정수값인 경우만 더하기
      final calories = meal['calories'];
      if (calories is int) {
        return sum + calories;
      }
      return sum;
    },
  );
}

 // 식사 기록 삭제
Future<void> _deleteMeal(String mealId, String date) async {
  try {
    print("Deleting meal with id: $mealId");
    await _mealRepository.deleteMeal(mealId);
    setState(() {
      _mealsByDate[date]?.removeWhere((meal) => meal['id'] == mealId);
      if (_mealsByDate[date]?.isEmpty ?? true) {
        _mealsByDate.remove(date);
      }
    });

    _updatePopupHandler(); // 상태 업데이트
    print("Meal deleted successfully.");
  } catch (e) {
    print("Error deleting meal: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.popupHandler.mealLevel > _currentMeal) {
          widget.popupHandler.triggerAnimation('eatingmeal', delayMilliseconds: 2000);
        } else {
          print("No significant meal level change, no animation triggered.");
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('날짜별 식단 기록'),
          backgroundColor: const Color(0xFFFFF9C4),
        ),
        body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '식사 기록 추가',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedMealType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMealType = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: '식사 종류',
                      border: OutlineInputBorder(),
                    ),
                    items: <String>['아침', '점심', '저녁', '간식']
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
                  flex: 3,
                  child: TextField(
                    controller: _mealController,
                    decoration: const InputDecoration(
                      labelText: '음식 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: '칼로리 (Kcal)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addMeal,
                  child: const Text('기록 추가'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(
              thickness: 2,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            const Text(
              '역대 식사 기록',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _mealsByDate.isEmpty
                  ? const Center(
                      child: Text('기록된 식사가 없습니다.'),
                    )
                  : ListView(
                      children: _mealsByDate.keys.map((date) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpansionTile(
                              title: Text(date),
                              children: _mealsByDate[date]!
                                  .map((meal) => ListTile(
                                        title: Text("${meal['meal']} (${meal['calories']} Kcal)"),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => _deleteMeal(meal['id'], date),
                                          tooltip: '삭제',
                                        ),
                                      ))
                                  .toList(),
                            ),
                            if (date == _getFormattedDate())
                              _buildCalorieSummary(date), // 날짜별 칼로리 요약 추가
                          ],
                        );
                      }).toList(),
                    ),
            ),
            // **하단에 고정된 요약 위젯 추가**
                  _buildCalorieSummary(_getFormattedDate()), // 오늘 날짜를 전달
          ],
        ),
      ),

      ),
    );
  }

  

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
} 
