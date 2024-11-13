import 'package:flutter/material.dart';
import 'package:gungangazi/services/TokenService.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../services/dio_service.dart';
import '../repositories/userHealth/supplement_repository.dart';
import '../dto/userHealth/supplementDto.dart';

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  _SupplementsPageState createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  final Map<DateTime, bool> _supplementTaken = {};
  final Map<DateTime, bool> _menstruationRecorded = {};
  DateTime _selectedDay = DateTime.now();
  final DioService dioService = DioService();
  late final SupplementRepository supplementRepository;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    supplementRepository = SupplementRepository(dioService: dioService,tokenService: TokenService());
    _initializeNotifications();
    _loadData();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(DateTime scheduledDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', 'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '예정된 생리일 알림',
      '생리 주기를 확인하세요.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _saveData() async {
    SupplementDto dto = SupplementDto(
      date: _selectedDay,
      supplementTaken: _supplementTaken[_selectedDay] ?? false,
      menstruationRecorded: _menstruationRecorded[_selectedDay] ?? false,
    );
    await supplementRepository.saveSupplement(dto);
  }

  Future<void> _loadData() async {
   final supplements = await supplementRepository.fetchSupplements();
  setState(() {
    for (var supplement in supplements) {
      _supplementTaken[supplement.date] = supplement.supplementTaken;
      _menstruationRecorded[supplement.date] = supplement.menstruationRecorded;
    }
  });
}

  void _toggleSupplementTaken() {
    setState(() {
      _supplementTaken[_selectedDay] = !(_supplementTaken[_selectedDay] ?? false);
      _saveData();
    });
  }

  void _toggleMenstruationRecorded() {
    setState(() {
      _menstruationRecorded[_selectedDay] = !(_menstruationRecorded[_selectedDay] ?? false);
      if (_menstruationRecorded[_selectedDay] == true) {
        _scheduleNotification(_selectedDay);
      }
      _saveData();
    });
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
                if (_supplementTaken[date] == true) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${date.day}')),
                  );
                } else if (_menstruationRecorded[date] == true) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${date.day}')),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleSupplementTaken,
            child: Text(
              _supplementTaken[_selectedDay] == true ? '영양제 복용 취소' : '영양제 복용 기록',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleMenstruationRecorded,
            child: Text(
              _menstruationRecorded[_selectedDay] == true ? '생리 기록 취소' : '생리 기록',
            ),
          ),
        ],
      ),
    );
  }
}
