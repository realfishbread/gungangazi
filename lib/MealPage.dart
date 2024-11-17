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
  int _mealLevel = 0; // 초기 MealLevel 설정
  String _selectedMealType = "식사"; // 기본 식사 타입 선택
  bool _isLoading = true; // 로딩 상태 플래그

  @override
  void initState() {
    super.initState();
    _mealRepository = MealRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _fetchMeals(); // 데이터 로드
  }

  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // 서버에서 모든 식사 기록 가져오기
  Future<void> _fetchMeals() async {
    try {
      print("Fetching meals from server...");
      List<MealDTO> meals = await _mealRepository.fetchAllMeals(); // 서버에서 데이터 가져오기
      print("Fetched meals: $meals");

      setState(() {
        for (var meal in meals) {
          if (_mealsByDate.containsKey(meal.date)) {
            _mealsByDate[meal.date]?.add(meal.meal);
          } else {
            _mealsByDate[meal.date] = [meal.meal];
          }
        }
        _mealLevel = ((_mealsByDate[_getFormattedDate()]?.length) ?? 0) * 200; // MealLevel 계산
        print("Updated MealLevel: $_mealLevel");
        _isLoading = false; // 로딩 완료
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
        date: currentDate,
        meal: meal,
        username: username ?? '',
        calories: calories,
        mealType: _selectedMealType,
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
      }
    } else {
      print("Invalid input: Meal or Calories is empty/invalid.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 조건에 따라 애니메이션 실행
        if (widget.popupHandler.mealLevel > widget.popupHandler.mealLevelThreshold) {
          widget.popupHandler.triggerAnimation('eatingmeal', delayMilliseconds: 2000);
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) // 로딩 상태 표시
            : Padding(
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
                                      .map((meal) => ListTile(
                                            title: Text(meal),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                // 삭제 기능 호출
                                              },
                                              tooltip: '삭제',
                                            ),
                                          ))
                                      .toList(),
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

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
