import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeUpTime;
  List<Map<String, String>> _sleepRecords = [];

  @override
  void initState() {
    super.initState();
    _loadSleepData(); // 앱 시작 시 데이터 로드
  }

  // 수면 시간 로컬 저장
  Future<void> _saveSleepDataLocally() async {
    if (_sleepTime != null && _wakeUpTime != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String formattedSleepTime = _sleepTime!.format(context);
      String formattedWakeUpTime = _wakeUpTime!.format(context);

      // 새로운 기록을 저장할 데이터로 변환
      Map<String, String> newRecord = {
        'date': formattedDate,
        'sleepTime': formattedSleepTime,
        'wakeUpTime': formattedWakeUpTime,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 이전에 저장된 데이터를 불러오기
      String? savedData = prefs.getString('sleepData');
      List<Map<String, String>> records = [];

      if (savedData != null) {
        try {
          // 저장된 데이터 불러오기
          List<dynamic> decodedData = json.decode(savedData);
          records = decodedData.map((item) {
            return Map<String, String>.from(item);
          }).toList();
        } catch (e) {
          print('저장된 데이터를 불러오는 중 오류 발생: $e');
        }
      }

      // 동일한 날짜의 기록이 있는지 확인하고 업데이트
      bool recordExists = false;
      for (int i = 0; i < records.length; i++) {
        if (records[i]['date'] == formattedDate) {
          records[i] = newRecord; // 동일한 날짜면 업데이트
          recordExists = true;
          break;
        }
      }

      if (!recordExists) {
        records.add(newRecord); // 동일한 날짜가 없으면 새로운 기록 추가
      }

      // 업데이트된 리스트를 다시 저장
      await prefs.setString('sleepData', json.encode(records));

      print('수면 데이터 로컬에 저장 성공: $records');

      // 저장 후 데이터 다시 로드
      _loadSleepData();
    } else {
      print('수면 시간 또는 기상 시간이 선택되지 않음');
    }
  }

  // 데이터베이스에 수면 시간 전송
  Future<void> _saveSleepDataToDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sleepData');

    if (savedData != null) {
      try {
        List<dynamic> data = json.decode(savedData);
        List<Map<String, String>> records = data.map((item) {
          return Map<String, String>.from(item);
        }).toList();

        // 예시 API URL로 데이터 전송
        final response = await http.post(
          Uri.parse('https://your-api-endpoint.com/saveSleepData'),  // API 엔드포인트 설정
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'records': records}),
        );

        if (response.statusCode == 200) {
          print('수면 데이터가 서버에 성공적으로 저장되었습니다.');
        } else {
          print('서버에 데이터 저장 실패: ${response.statusCode}');
        }
      } catch (e) {
        print('서버로 데이터를 전송하는 중 오류 발생: $e');
      }
    } else {
      print('로컬에 저장된 수면 데이터가 없습니다.');
    }
  }

  // 로컬에서 수면 데이터 가져오기
  Future<void> _loadSleepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('sleepData');

    if (savedData != null) {
      try {
        List<dynamic> data = json.decode(savedData);
        setState(() {
          _sleepRecords = data.map((item) {
            return Map<String, String>.from(item);
          }).toList();
        });
        print('수면 데이터 로드 성공: $_sleepRecords');
      } catch (e) {
        print('수면 데이터를 로드하는 중 오류 발생: $e');
        setState(() {
          _sleepRecords = [];
        });
      }
    } else {
      setState(() {
        _sleepRecords = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 정보 가져오기
    final screenSize = MediaQuery.of(context).size;
    final bool isWeb = screenSize.width > 600; // 너비가 600 이상이면 웹으로 간주

    return Scaffold(
      appBar: AppBar(
        title: const Text('수면 정보'),
        backgroundColor: const Color(0xFFFFF9C4),
      ),
      // 웹 화면일 경우, 중앙에 고정된 컨테이너로 레이아웃 설정
      body: Center(
        child: Container(
          width: isWeb ? 800 : screenSize.width, // 웹일 경우 너비를 800으로 제한
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _selectSleepTime(context),
                    icon: const Icon(Icons.bedtime),
                    label: Text(
                      _sleepTime == null
                          ? '수면 시간 선택'
                          : '수면 시간: ${_sleepTime!.format(context)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 크기 조정
                      minimumSize: const Size(140, 40), // 최소 크기 설정
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectWakeUpTime(context),
                    icon: const Icon(Icons.wb_sunny),
                    label: Text(
                      _wakeUpTime == null
                          ? '기상 시간 선택'
                          : '기상 시간: ${_wakeUpTime!.format(context)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 크기 조정
                      minimumSize: const Size(140, 40), // 최소 크기 설정
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSleepDataLocally,
                child: const Text('로컬에 저장하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 크기 조정
                  minimumSize: const Size(140, 40), // 최소 크기 설정
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _sleepRecords.isEmpty
                    ? const Center(child: Text('저장된 수면 기록이 없습니다.'))
                    : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('날짜')),
                      DataColumn(label: Text('수면 시간')),
                      DataColumn(label: Text('기상 시간')),
                    ],
                    rows: _sleepRecords.map((record) {
                      return DataRow(cells: [
                        DataCell(Text(record['date']!)),
                        DataCell(Text(record['sleepTime']!)),
                        DataCell(Text(record['wakeUpTime']!)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10), // 리스트와 버튼 사이 간격 추가
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _saveSleepDataToDatabase,
                  child: const Text('데이터베이스로 전송하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 크기 조정
                    minimumSize: const Size(140, 40), // 최소 크기 설정
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 수면 시간 선택
  Future<void> _selectSleepTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _sleepTime) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }

  // 기상 시간 선택
  Future<void> _selectWakeUpTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }
}
