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
  final Map<String, List<Map<String, dynamic>>> _mealsByDate = {}; // 식사 기록 저장
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  late MealRepository _mealRepository;
  bool _isAddingRecord = false; // 입력 필드 표시 여부
  int _mealLevel = 0;
  String _selectedMealType = "식사";
  bool _isLoading = true;
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
      String? gender = await DioService().getGender();
      setState(() {
        _gender = gender;
      });
    } catch (e) {
      print('Error fetching gender: $e');
    }
  }

  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Widget _buildCalorieSummary(String date) {
    final int totalCalories = _calculateTotalCalories(date);
    final int recommendedCalories = (_gender == '여성') ? 2000 : 2600;

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

  Future<void> _fetchMeals() async {
    try {
      List<MealDTO> meals = await _mealRepository.fetchAllMeals();
      setState(() {
        _mealsByDate.clear();
        for (var meal in meals) {
          final mealData = {
            'id': meal.id,
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
        _mealLevel = ((_mealsByDate[_getFormattedDate()]?.length) ?? 0) * 200;
        _isLoading = false;
        _updatePopupHandler();
      });
    } catch (e) {
      print('Error loading meals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePopupHandler() {
    int currentHour = DateTime.now().hour;
    if (currentHour < 6) {
      return;
    }
    widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: _mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel,
    );
  }

  void _toggleAddRecord() {
    setState(() {
      _isAddingRecord = !_isAddingRecord;
    });
  }

  void _addMeal() async {
    final String meal = _mealController.text.trim();
    final int? calories = int.tryParse(_caloriesController.text.trim());
    if (meal.isNotEmpty && calories != null) {
      final String currentDate = _getFormattedDate();
      String? username = await TokenService().getUsername();
      final MealDTO newMeal = MealDTO(
        id: '',
        date: currentDate,
        meal: meal,
        username: username ?? '',
        calories: calories,
        meal_type: _selectedMealType,
      );

      try {
        await _mealRepository.addMeal(newMeal);
        await _fetchMeals();
        setState(() {
          _mealController.clear();
          _caloriesController.clear();
          _isAddingRecord = false; // 입력 폼 닫기
        });
        _updatePopupHandler();
      } catch (e) {
        print('Error adding meal: $e');
      }
    } else {
      print("Invalid input: Meal or Calories is empty/invalid.");
    }
  }

  int _calculateTotalCalories(String date) {
    if (!_mealsByDate.containsKey(date)) return 0;
    return _mealsByDate[date]!.fold<int>(
      0,
      (sum, meal) {
        final calories = meal['calories'];
        if (calories is int) {
          return sum + calories;
        }
        return sum;
      },
    );
  }

  Widget _getCalorieStatusWidget(String date) {
    final int totalCalories = _calculateTotalCalories(date);
    final int recommendedCalories = (_gender == '여성') ? 2000 : 2600;
    final int calorieDifference = totalCalories - recommendedCalories;

    if (calorieDifference > 0) {
      return Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.red),
          const SizedBox(width: 5),
          Text(
            "초과 ${calorieDifference.abs()} Kcal",
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 5),
          Text(
            "남음 ${calorieDifference.abs()} Kcal",
            style: const TextStyle(color: Colors.green, fontSize: 14),
          ),
        ],
      );
    }
  }

  Future<void> _deleteMeal(String mealId, String date) async {
    try {
      await _mealRepository.deleteMeal(mealId);
      setState(() {
        _mealsByDate[date]?.removeWhere((meal) => meal['id'] == mealId);
        if (_mealsByDate[date]?.isEmpty ?? true) {
          _mealsByDate.remove(date);
        }
      });
      _updatePopupHandler();
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
                    ElevatedButton(
                      onPressed: _toggleAddRecord,
                      child: Text(_isAddingRecord ? '취소' : '식사 기록 추가'),
                    ),
                    if (_isAddingRecord)
                      Column(
                        children: [
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
                          const Divider(thickness: 2),
                        ],
                      ),
                    Expanded(
                      child: _mealsByDate.isEmpty
                          ? const Center(child: Text('기록된 식사가 없습니다.'))
                          : ListView(
                              children: _mealsByDate.keys.map((date) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            date,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          _getCalorieStatusWidget(date),
                                        ],
                                      ),
                                      children: _mealsByDate[date]!
                                          .map((meal) => ListTile(
                                                title: Text("${meal['meal']} (${meal['calories']} Kcal)"),
                                                trailing: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () => _deleteMeal(meal['id'], date),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                    _buildCalorieSummary(_getFormattedDate()),
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

