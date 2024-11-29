import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/dio_service.dart';
import '../repositories/userHealth/supplement_repository.dart';
import '../dto/userHealth/supplementDto.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart';
import 'package:intl/intl.dart';



class SupplementsPage extends StatefulWidget {
  final PopupHandler popupHandler;
  const SupplementsPage({Key? key, required this.popupHandler}) : super(key: key);

  @override
  _SupplementsPageState createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  final Map<DateTime, bool> _supplementTaken = {};
  final Set<DateTime> _selectedMenstruationDays = {};
  String? _gender;
  DateTime _selectedDay = DateTime.now();
  final DioService dioService = DioService();
  final TokenService tokenService = TokenService();
  late final SupplementRepository supplementRepository;
  bool _addSupplement = false;

  @override
  void initState() {
    super.initState();
    supplementRepository = SupplementRepository(dioService: dioService, tokenService: tokenService);
    _loadData();
    _fetchGender();
  }

  Future<void> _fetchGender() async {
    String? gender = await dioService.getGender();
    print('Fetched gender: $gender');
    setState(() {
      _gender = gender;
    });
  }

  // 상태 변경 및 데이터 저장 로직 개선
void _updateMenstruationOrSupplement(DateTime date, {bool? isMenstruation, bool? isSupplement}) {
  setState(() {
    // 생리 기록 여부 업데이트
    if (isMenstruation != null) {
      if (isMenstruation) {
        _selectedMenstruationDays.add(date);
      } else {
        _selectedMenstruationDays.remove(date);
      }
    }

    // 영양제 복용 여부 업데이트
    if (isSupplement != null) {
      _supplementTaken[date] = isSupplement;
    }

    // 디버그 출력
    print('_selectedMenstruationDays: $_selectedMenstruationDays');
    print('_supplementTaken: $_supplementTaken');
  });
}

  Future<void> _saveData() async {
  String? username = await tokenService.getUsername();
  if (username == null) {
    print("Username을 가져올 수 없습니다.");
    return;
  }

  // 중복 제거를 위한 Set 사용
  final Set<DateTime> uniqueDates = {..._selectedMenstruationDays, ..._supplementTaken.keys};

  try {
    await Future.wait(uniqueDates.map((date) async {
      

      // DTO 생성
      SupplementDto dto = SupplementDto(
      date: date,
      supplement_taken: _supplementTaken[date] ?? false, // 기본값 false
      menstruation_recorded: _selectedMenstruationDays.contains(date), // 생리 기록 여부
      username: username,
    );

      print("Saving DTO: ${dto.toJson()}");
      await supplementRepository.saveSupplement(dto);
    }));

    print("All data saved successfully");

    // 애니메이션 상태 업데이트
    setState(() {
      _addSupplement = true;
    });

    // 데이터 다시 로드
    await _loadData();
  } catch (e) {
    print("Error while saving data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터 저장 중 오류가 발생했습니다.')),
    );
  }
}


  Future<void> _loadData() async {
  try {
    final supplements = await supplementRepository.fetchSupplements();
    setState(() {
      _supplementTaken.clear();
      _selectedMenstruationDays.clear();
      for (var supplement in supplements) {
        _supplementTaken[supplement.date] = supplement.supplement_taken;
        if (supplement.menstruation_recorded) {
          _selectedMenstruationDays.add(supplement.date);
        }
      }
    });

    print('_supplementTaken: $_supplementTaken');
    print('_selectedMenstruationDays: $_selectedMenstruationDays');
  } catch (e) {
    print("Error while loading data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터 로드 중 오류가 발생했습니다.')),
    );
  }
}


 Future<void> _fetchSingleDayData(DateTime selectedDay) async {
  String? username = await tokenService.getUsername();
  if (username == null) {
    print("Username을 가져올 수 없습니다.");
    return;
  }

  try {
    final singleDayData = await supplementRepository.fetchSingleSupplement(username, selectedDay);

    setState(() {
      _supplementTaken[selectedDay] = singleDayData?.supplement_taken ?? false;
      if (singleDayData?.menstruation_recorded ?? false) {
        _selectedMenstruationDays.add(selectedDay);
      } else {
        _selectedMenstruationDays.remove(selectedDay);
      }
    });

    print('Single day data fetched: $singleDayData');
    print('_selectedMenstruationDays after update: $_selectedMenstruationDays');
  } catch (e) {
    print('Failed to fetch single day data: $e');
  }
}

// BottomSheet 로직 개선
void _showBottomSheet(DateTime selectedDay) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          bool isSupplementTaken = _supplementTaken[selectedDay] ?? false;
          bool isMenstruationRecorded = _selectedMenstruationDays.contains(selectedDay);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '날짜: ${DateFormat('yyyy-MM-dd').format(selectedDay)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('영양제 복용'),
                    Switch(
                      value: isSupplementTaken,
                      onChanged: (value) {
                        setModalState(() {
                          isSupplementTaken = value;
                        });
                        _updateMenstruationOrSupplement(
                          selectedDay,
                          isSupplement: isSupplementTaken,
                        );
                      },
                    ),
                  ],
                ),
                if (_gender != '남성')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('생리 기록'),
                      Switch(
                        value: isMenstruationRecorded,
                        onChanged: (value) {
                          setModalState(() {
                            isMenstruationRecorded = value;
                          });
                          _updateMenstruationOrSupplement(
                            selectedDay,
                            isMenstruation: isMenstruationRecorded,
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _saveData();
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}





  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_addSupplement) {
          widget.popupHandler.triggerAnimation('medication', delayMilliseconds: 1000);
        }
        return true;
      },
      child: Scaffold(
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
                _showBottomSheet(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, focusedDay) {
                  DateTime dateOnly = DateTime(date.year, date.month, date.day);

                  if (_selectedMenstruationDays.contains(dateOnly) && (_supplementTaken[dateOnly] == true)) {
                    // 생리와 영양제 둘 다 체크된 경우 보라색
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B51E0).withOpacity(0.5), // 보라색
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('${date.day}')),
                    );
                  } else if (_selectedMenstruationDays.contains(dateOnly)) {
                    // 생리만 체크된 경우 빨간색
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 235, 63, 51).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('${date.day}')),
                    );
                  } else if (_supplementTaken[dateOnly] == true) {
                    // 영양제만 체크된 경우 파란색
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9ADCFF).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('${date.day}')),
                    );
                  }
                  return null; // 아무 것도 체크되지 않은 경우 기본 스타일
                },
              ),

            ),
          ],
        ),
      ),
    );
  }
}
