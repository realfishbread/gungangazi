import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식화를 위한 패키지

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final Map<String, List<String>> _mealsByDate = {};  // 날짜별 식사 기록을 저장할 Map
  final TextEditingController _mealController = TextEditingController();

  // 현재 날짜를 yyyy-MM-dd 형식으로 반환하는 함수
  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // 새로운 식사 기록을 추가하는 함수
  void _addMeal() {
    final String meal = _mealController.text.trim();
    if (meal.isNotEmpty) {
      setState(() {
        final String currentDate = _getFormattedDate();
        if (_mealsByDate.containsKey(currentDate)) {
          _mealsByDate[currentDate]?.add(meal);
        } else {
          _mealsByDate[currentDate] = [meal];
        }
        _mealController.clear();
      });
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
                    title: Text(date), // 날짜별로 그룹화된 타일
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

