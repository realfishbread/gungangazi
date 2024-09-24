import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  _SupplementsPageState createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  // 캘린더에 표시할 데이터 저장
  final Map<DateTime, bool> _supplementTaken = {};
  final Map<DateTime, bool> _menstruationRecorded = {}; // 생리 기록을 저장할 변수
  DateTime _selectedDay = DateTime.now(); // 오늘 날짜를 기준으로 선택한 날짜 관리
  int _cycleLength = 28; // 생리 주기 기본값
  final int _periodLength = 5; // 생리 기간 (5일로 가정)

  DateTime? _lastMenstruationDate; // 마지막 생리일을 저장하는 변수
  List<DateTime> _predictedMenstruationDates = []; // 예측된 생리 주기 날짜 리스트

  // 마지막 생리일로부터 예측된 생리 주기 계산
  void _predictNextMenstruation() {
    if (_lastMenstruationDate != null) {
      _predictedMenstruationDates.clear(); // 예측 주기 초기화
      for (int i = 1; i <= 12; i++) { // 12개월 동안 예측
        DateTime nextPeriodStart = _lastMenstruationDate!.add(Duration(days: _cycleLength * i));
        for (int j = 0; j < _periodLength; j++) {
          _predictedMenstruationDates.add(nextPeriodStart.add(Duration(days: j)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            // 날짜에 맞게 영양제 복용 여부 및 생리 기록 표시
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, focusedDay) {
                // 생리 주기 예측된 날짜를 다른 색상으로 표시
                if (_predictedMenstruationDates.contains(date)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5), // 예측된 생리 주기 배경색
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${date.day}')),
                  );
                }
                return null;
              },
              markerBuilder: (context, date, events) {
                List<Widget> markers = [];
                if (_supplementTaken[date] == true) {
                  markers.add(const Icon(Icons.medication, color: Colors.yellow, size: 16));
                }
                if (_menstruationRecorded[date] == true) {
                  markers.add(const Icon(Icons.circle, color: Colors.red, size: 8));
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: markers,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // 선택한 날짜의 영양제 복용 여부 토글
                _supplementTaken[_selectedDay] =
                !(_supplementTaken[_selectedDay] ?? false);
              });
            },
            child: Text(_supplementTaken[_selectedDay] == true
                ? '영양제 복용 취소'
                : '영양제 복용 기록'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // 선택한 날짜의 생리 기록 여부 토글
                _menstruationRecorded[_selectedDay] =
                !(_menstruationRecorded[_selectedDay] ?? false);
                if (_menstruationRecorded[_selectedDay] == true) {
                  _lastMenstruationDate = _selectedDay; // 마지막 생리일 기록
                  _predictNextMenstruation(); // 생리 주기 예측
                } else if (_lastMenstruationDate == _selectedDay) {
                  _lastMenstruationDate = null; // 마지막 생리일 초기화
                  _predictedMenstruationDates.clear(); // 예측된 주기 초기화
                }
              });
            },
            child: Text(_menstruationRecorded[_selectedDay] == true
                ? '생리 기록 취소'
                : '생리 기록'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('생리 주기: '),
              DropdownButton<int>(
                value: _cycleLength,
                items: List.generate(11, (index) => 20 + index).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value일'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _cycleLength = newValue;
                      if (_lastMenstruationDate != null) {
                        _predictNextMenstruation(); // 주기 변경 시 예측 갱신
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
