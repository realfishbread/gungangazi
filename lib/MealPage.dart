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
  late MealRepository _mealRepository;
  int _mealLevel = 0; // 초기 mealLevel 설정

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

  // 서버에서 식사 기록 가져오기
  void _fetchMeals() async {
    final String currentDate = _getFormattedDate();
    try {
      List<MealDTO> meals = await _mealRepository.fetchMealsByDate(currentDate);
      setState(() {
        _mealsByDate[currentDate] = meals.map((meal) => meal.meal).toList();
        _mealLevel = _mealsByDate[currentDate]!.length * 200; // 기록된 식사 수에 따라 mealLevel 설정
      });
      _checkMealStatus();
    } catch (e) {
      print('Error loading meals: $e');
    }
  }

  // 식사 상태 확인하여 PopupHandler 업데이트
  void _checkMealStatus() {
    String today = _getFormattedDate();
    int todayMealLevel = _mealsByDate[today]?.length ?? 0;

    widget.popupHandler.updateStatus(
      newWaterLevel: widget.popupHandler.waterLevel,
      newMealLevel: _mealLevel, // 현재 mealLevel 반영
    );
  }

  // 새로운 식사 기록 추가 시 PopupHandler 상태 업데이트
  void _addMeal() async {
    final String meal = _mealController.text.trim();
    if (meal.isNotEmpty) {
      final String currentDate = _getFormattedDate();
      String? username = await TokenService().getUsername();
      final MealDTO newMeal = MealDTO(
        date: currentDate,
        meal: meal,
        username: username ?? '',
      );

      try {
        await _mealRepository.addMeal(newMeal);
        setState(() {
          if (_mealsByDate.containsKey(currentDate)) {
            _mealsByDate[currentDate]?.add(meal);
          } else {
            _mealsByDate[currentDate] = [meal];
          }
          _mealLevel += 200; // 식사 추가 시 mealLevel 200 증가
          _mealController.clear();
        });
        _checkMealStatus(); // 업데이트된 mealLevel 적용
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
            TextField(
              controller: _mealController,
              decoration: const InputDecoration(
                labelText: '식사 내용 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addMeal,
              child: const Text('식사 추가'),
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
    super.dispose();
  }
}
