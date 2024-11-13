import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../dto/userHealth/meal_dto.dart';
import '../../repositories/userHealth/meal_repository.dart';
import '../../services/dio_service.dart';
import '../../services/TokenService.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final Map<String, List<String>> _mealsByDate = {};
  final TextEditingController _mealController = TextEditingController();
  late MealRepository _mealRepository;

  @override
  void initState() {
    super.initState();
    _mealRepository = MealRepository(
      dioService: DioService(),
      tokenService: TokenService(),
    );
    _fetchMeals(); // 앱 시작 시 오늘 날짜의 식사 기록을 불러옴
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
        _mealsByDate[currentDate] = meals.map((meal) => meal.mealContent).toList();
      });
    } catch (e) {
      print('Error loading meals: $e');
    }
  }

  // 새로운 식사 기록을 추가하고 서버에 저장하는 함수
  void _addMeal() async {
    final String mealContent = _mealController.text.trim();
    if (mealContent.isNotEmpty) {
      final String currentDate = _getFormattedDate();
      String? username = await TokenService().getUsername();  // username을 가져옴
      final MealDTO newMeal = MealDTO(
        date: currentDate,
        mealContent: mealContent,
        username: username ?? '',  // username을 추가
      );

      try {
        await _mealRepository.addMeal(newMeal);
        setState(() {
          if (_mealsByDate.containsKey(currentDate)) {
            _mealsByDate[currentDate]?.add(mealContent);
          } else {
            _mealsByDate[currentDate] = [mealContent];
          }
          _mealController.clear();
        });
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
}

