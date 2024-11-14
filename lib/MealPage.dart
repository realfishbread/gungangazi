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
  final TextEditingController _caloriesController = TextEditingController(); // 칼로리 입력 컨트롤러 추가
  late MealRepository _mealRepository;
  int _mealLevel = 0;
  String _selectedMealType = '식사'; // 기본값을 "식사"로 설정

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
      List<MealDTO> meals = await _mealRepository.fetchAllMeals();
      setState(() {
        for (var meal in meals) {
          String mealEntry = '${meal.mealType} - ${meal.meal} (${meal.calories} kcal)';
          if (_mealsByDate.containsKey(meal.date)) {
            _mealsByDate[meal.date]?.add(mealEntry);
          } else {
            _mealsByDate[meal.date] = [mealEntry];
          }
        }
        _mealLevel = _mealsByDate[_getFormattedDate()]?.length ?? 0 * 200;
      });
      _checkMealStatus();
    } catch (e) {
      print('Error loading meals: $e');
    }
  }

  // 식사 상태 확인하여 PopupHandler 업데이트
  void _checkMealStatus() {
    widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: _mealLevel,
      newSleepLevel: widget.popupHandler.sleepLevel,
    );
  }

  // 새로운 식사 기록 추가 시 PopupHandler 상태 업데이트
  void _addMeal() async {
    final String meal = _mealController.text.trim();
    final int? calories = int.tryParse(_caloriesController.text.trim());
    if (meal.isNotEmpty && calories != null) {
      final String currentDate = _getFormattedDate();
      String? username = await TokenService().getUsername();
      final MealDTO newMeal = MealDTO(
        date: currentDate,
        meal: meal,
        username: username ?? '',
        calories: calories,
        mealType: _selectedMealType,
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
          _mealLevel += 200;
          _mealController.clear();
          _caloriesController.clear();
        });
        _checkMealStatus();
      } catch (e) {
        print('Error adding meal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날짜별 식단 기록'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: _selectedMealType,
              items: ['식사', '간식'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMealType = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mealController,
              decoration: const InputDecoration(
                labelText: '식사/간식 내용 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '칼로리 입력 (kcal)',
                border: OutlineInputBorder(),
              ),
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
                              .map((meal) => ListTile(
                                    title: Text(meal),
                                  ))
                              .toList(),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose(); // 칼로리 입력 컨트롤러 해제
    super.dispose();
  }
}

