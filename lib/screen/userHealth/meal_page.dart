import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../dto/userHealth/meal_dto.dart';
import '../../../repositories/userHealth/meal_repository.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../character/popup_handler.dart';
import 'package:gungangazi/screen/character/character_status.dart';
import 'package:provider/provider.dart'; // ✅ Provider 추가

class MealPage extends StatefulWidget {
  final PopupHandler popupHandler;
  final CharacterStatus characterStatus; // ✅ 추가

  const MealPage({Key? key, required this.popupHandler, required this.characterStatus}) : super(key: key);

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
  int _recommendedCalories = 2000; // 기본 권장 칼로리 값
  int _age = 0; // 사용자 나이
  int _weight = 0; // 사용자 체중
  int _height =0;

  DateTime now = DateTime.now();



  @override
  void initState() {
    super.initState();
    _mealRepository = MealRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _fetchUserInfo(); // 사용자 정보 가져오기
    _fetchMeals(); // 식사 기록 가져오기
    final characterStatus = context.read<CharacterStatus>(); // ✅ Provider에서 가져오기
   
    _currentMeal = characterStatus.meal_level;
  }


   Future<void> _fetchUserInfo() async {
  try {
    final userInfo = await DioService().getUserInfo(); // 사용자 정보 가져오기
    if (userInfo != null) {
      setState(() {
        _gender = userInfo['gender'];

        // 나이 추출 (숫자만)
        _age = int.tryParse(userInfo['age']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;

        // 체중 추출 (숫자만)
        _weight = int.tryParse(userInfo['weight']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;

        // 키 추출 (숫자만)
        _height = int.tryParse(userInfo['height']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;

        // 권장 칼로리 계산
        _recommendedCalories = _calculateRecommendedCalories(
          _age,
          _gender ?? '남성',
          _weight,
          _height,
        );
      });
    }
  } catch (e) {
    print('Error fetching user info: $e');
  }
}

int _calculateRecommendedCalories(int age, String gender, int weight, int height) {
  // 키는 cm 단위로 받아오고, 계산에서는 m 단위로 변환 필요
  double heightInMeters = height / 100.0;
  double bmr;

  if (gender == '남성') {
    // Harris-Benedict 방정식: 남성용
    bmr = 88.362 + (13.397 * weight) + (4.799 * heightInMeters * 100) - (5.677 * age);
  } else if (gender == '여성') {
    // Harris-Benedict 방정식: 여성용
    bmr = 447.593 + (9.247 * weight) + (3.098 * heightInMeters * 100) - (4.330 * age);
  } else {
    // 기본값 처리 (성별이 명확하지 않은 경우)
    bmr = 0.0;
  }

  // 활동 계수: 1.55 = 적당한 활동
  return (bmr * 1.55).round();
}


  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // 기존 _buildCalorieSummary() 메서드 수정
Widget _buildCalorieSummary(String date) {
  final int totalCalories = _calculateTotalCalories(date);
  final int remainingCalories = _recommendedCalories - totalCalories;
  final bool isExceeding = remainingCalories < 0;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: isExceeding ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExceeding ? Colors.red : Colors.green,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "오늘 총 칼로리 섭취: $totalCalories Kcal",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (isExceeding)
            Text(
              "초과된 칼로리: ${totalCalories - _recommendedCalories} Kcal",
              style: const TextStyle(color: Colors.red, fontSize: 14),
            )
          else
            Text(
              "남은 칼로리: $remainingCalories Kcal",
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
        ],
      ),
    ),
  );
}
Widget _getCalorieStatusWidget(String date) {
    final int totalCalories = _calculateTotalCalories(date);
    final int calorieDifference = totalCalories - _recommendedCalories;

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
  // 서버에서 모든 식사 기록 가져오기
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

 
   

  // PopupHandler 상태 업데이트
  Future<void> _updatePopupHandler() async{
    print("Updating PopupHandler...");
    final characterStatus = Provider.of<CharacterStatus>(context, listen: false); // ✅ 안전하게 가져오기
    
    
    await characterStatus.updateStatus(
      newWaterLevel: characterStatus.water_level,
      newMealLevel: _mealLevel,
      newSleepLevel: characterStatus.sleep_level,
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
        await _updatePopupHandler(); // 상태 업데이트 완료 후

        // 저장 후 데이터를 새로고침
        await _fetchMeals(); // 최신 데이터 가져오기
        setState(() {
          _mealController.clear();
          _caloriesController.clear();
        });

       // ✅ 해결 방법: `_checkStatus();`를 `await`으로 실행
      
      
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

Color _getMealTypeColor(String? mealType) {
  switch (mealType) {
    case '아침':
      return const Color.fromARGB(255, 253, 238, 190); // 아침: 밝은 주황색
    case '점심':
      return Color.fromARGB(255, 197, 255, 243); // 점심: 밝은 초록색
    case '저녁':
      return Color.fromARGB(255, 231, 217, 253); // 저녁: 밝은 파란색
    case '간식':
      return Color.fromARGB(255, 162, 209, 173); // 간식: 밝은 분홍색
    default:
      return Colors.grey[200]!; // 기본: 밝은 회색
  }
}

Future<void> _checkStatus() async {
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  int currentHour = DateTime.now().hour; // 현재 시간 가져오기
  final characterStatus = context.read<CharacterStatus>(); // ✅ 불필요한 재빌드 방지
  int todayMealIntake = characterStatus.meal_level;

  // 저녁 10시 이후인지 확인
  if (todayMealIntake > _currentMeal) {
    if (currentHour >= 22) {
      // ✅ 저녁 10시 이후일 경우 다른 애니메이션 실행
      _currentMeal=characterStatus.meal_level;
      await widget.popupHandler.triggerAnimation('0ammeal', delayMilliseconds: 2000);
    } else {
      // ✅ 저녁 10시 이전일 경우 기존 애니메이션 실행
       _currentMeal=characterStatus.meal_level;
      await widget.popupHandler.triggerAnimation('eatingmeal', delayMilliseconds: 2000);
    }
  }
}

  @override
  Widget build(BuildContext context) {
   return PopScope(
    canPop: true,
    onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _checkStatus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('날짜별 식단 기록'),
        backgroundColor: const Color(0xFFFFF9C4),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("권장 칼로리 계산 방법"),
                  content: const Text(
                    "권장 칼로리는 Harris-Benedict 방정식을 기반으로 계산됩니다:\n\n"
                    "남성:\n"
                    "  BMR = 88.362 + (13.397 × 체중(kg)) + (4.799 × 키(cm)) - (5.677 × 나이)\n\n"
                    "여성:\n"
                    "  BMR = 447.593 + (9.247 × 체중(kg)) + (3.098 × 키(cm)) - (4.330 × 나이)\n\n"
                    "활동 계수(1.55)를 적용하여 최종 권장 칼로리를 계산합니다:\n"
                    "  권장 칼로리 = BMR × 1.55\n\n"
                    "사용자의 키, 체중, 나이를 기반으로 정확히 계산합니다.",
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF9C4),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('기록 추가'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 2, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      '역대 식사 기록',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
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
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        _getCalorieStatusWidget(date),
                                      ],
                                    ),
                                    children: _mealsByDate[date]!
                                        .map((meal) => Container(
                                              decoration: BoxDecoration(
                                                color: _getMealTypeColor(meal['meal_type']), // 배경색
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              child: ListTile(
                                                title: Text(
                                                  "${meal['meal_type']}     ${meal['meal']} [${meal['calories']} Kcal]",
                                                  style: const TextStyle(
                                                      fontSize: 14, color: Colors.black),
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () =>
                                                      _deleteMeal(meal['id'], date),
                                                  tooltip: '삭제',
                                                ),
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
}