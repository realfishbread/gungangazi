import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  _SupplementsPageState createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  final Map<DateTime, bool> _supplementTaken = {};
  final Map<DateTime, bool> _menstruationRecorded = {};
  DateTime _selectedDay = DateTime.now();
  int _cycleLength = 28;
  int _periodLength = 5;
  DateTime? _lastMenstruationDate;
  final List<DateTime> _predictedMenstruationDates = [];

  // 알림을 위한 플러그인 인스턴스 생성
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // 알림 초기화
    _loadData(); // 저장된 데이터 불러오기
  }

  // 알림 초기화
  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones(); // 타임존 초기화

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림 예약하기
  Future<void> _scheduleNotification(DateTime scheduledDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your_channel_id', 'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '예정된 생리일 알림',
      '생리 주기를 확인하세요.',
      tz.TZDateTime.from(scheduledDate, tz.local), // 예약 시간
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 데이터 불러오기
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final supplementData = prefs.getStringList('supplementTaken');
    if (supplementData != null) {
      for (var entry in supplementData) {
        final date = DateTime.parse(entry);
        _supplementTaken[date] = true;
      }
    }

    final menstruationData = prefs.getStringList('menstruationRecorded');
    if (menstruationData != null) {
      for (var entry in menstruationData) {
        final date = DateTime.parse(entry);
        _menstruationRecorded[date] = true;
      }
    }

    final lastMenstruation = prefs.getString('lastMenstruationDate');
    if (lastMenstruation != null) {
      _lastMenstruationDate = DateTime.parse(lastMenstruation);
      _predictNextMenstruation();
    }

    setState(() {});
  }

  // 데이터 저장하기
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final supplementData = _supplementTaken.keys
        .where((date) => _supplementTaken[date] == true)
        .map((date) => date.toIso8601String())
        .toList();
    prefs.setStringList('supplementTaken', supplementData);

    final menstruationData = _menstruationRecorded.keys
        .where((date) => _menstruationRecorded[date] == true)
        .map((date) => date.toIso8601String())
        .toList();
    prefs.setStringList('menstruationRecorded', menstruationData);

    if (_lastMenstruationDate != null) {
      prefs.setString('lastMenstruationDate', _lastMenstruationDate!.toIso8601String());
    } else {
      prefs.remove('lastMenstruationDate');
    }
  }

  // 페이지 나갈 때 데이터 저장
  @override
  void dispose() {
    _saveData();
    super.dispose();
  }

  // 생리 주기 예측 및 알림 예약
  void _predictNextMenstruation() {
    if (_lastMenstruationDate != null) {
      _predictedMenstruationDates.clear();
      for (int i = 1; i <= 12; i++) {
        DateTime nextPeriodStart = _lastMenstruationDate!.add(Duration(days: _cycleLength * i));
        for (int j = 0; j < _periodLength; j++) {
          DateTime predictedDate = nextPeriodStart.add(Duration(days: j));
          _predictedMenstruationDates.add(predictedDate);

          // 생리 예측 날짜마다 알림 예약
          _scheduleNotification(predictedDate);
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
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, focusedDay) {
                if (_predictedMenstruationDates.contains(date)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
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
                _supplementTaken[_selectedDay] = !(_supplementTaken[_selectedDay] ?? false);
              });
            },
            child: Text(_supplementTaken[_selectedDay] == true ? '영양제 복용 취소' : '영양제 복용 기록'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _menstruationRecorded[_selectedDay] = !(_menstruationRecorded[_selectedDay] ?? false);
                if (_menstruationRecorded[_selectedDay] == true) {
                  _lastMenstruationDate = _selectedDay;
                  _predictNextMenstruation();
                } else if (_lastMenstruationDate == _selectedDay) {
                  _lastMenstruationDate = null;
                  _predictedMenstruationDates.clear();
                }
              });
            },
            child: Text(_menstruationRecorded[_selectedDay] == true ? '생리 기록 취소' : '생리 기록'),
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
                        _predictNextMenstruation();
                      }
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('생리 기간: '),
              DropdownButton<int>(
                value: _periodLength,
                items: List.generate(5, (index) => 3 + index).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value일'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _periodLength = newValue;
                      if (_lastMenstruationDate != null) {
                        _predictNextMenstruation();
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

