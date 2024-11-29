import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/dio_service.dart';
import '../repositories/userHealth/supplement_repository.dart';
import '../dto/userHealth/supplementDto.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart';


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

  Future<void> _saveData() async {
  String? username = await tokenService.getUsername();
  if (username == null) {
    print("Username을 가져올 수 없습니다.");
    return;
  }

  final Set<DateTime> uniqueDates = {..._selectedMenstruationDays, ..._supplementTaken.keys};

  try {
    // 모든 날짜를 비동기로 저장
    await Future.wait(uniqueDates.map((date) async {
      SupplementDto dto = SupplementDto(
        date: date,
        supplement_taken: _supplementTaken[date] ?? false, // 기본값을 false로 설정
        menstruation_recorded: _selectedMenstruationDays.contains(date),
        username: username,
      );
      print("Saving DTO: ${dto.toJson()}");
      await supplementRepository.saveSupplement(dto); // 서버에 데이터 저장
    }));

    print("All data saved successfully");
    setState(() {
      _addSupplement = true; // 저장 성공 시 애니메이션 활성화
    });

    // 데이터 동기화
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

  // API를 통해 선택된 날짜의 데이터를 가져옴
  try {
    final singleDayData = await supplementRepository.fetchSingleSupplement(
      username,
      selectedDay,
    );

    setState(() {
      // 선택된 날짜 데이터만 반영
      _supplementTaken[selectedDay] = singleDayData?.supplement_taken ?? false;
      if (singleDayData?.menstruation_recorded ?? false) {
        _selectedMenstruationDays.add(selectedDay);
      } else {
        _selectedMenstruationDays.remove(selectedDay);
      }
    });

    print('Single day data fetched: $singleDayData');
  } catch (e) {
    print('Failed to fetch single day data: $e');
  }
}

void _showBottomSheet(DateTime selectedDay) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return FutureBuilder<void>(
        future: _fetchSingleDayData(selectedDay), // 선택된 날짜의 데이터를 가져옴
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 표시
          }

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              // 최신 데이터를 반영하여 Switch 초기화
              bool initialSupplementTaken = _supplementTaken[selectedDay] ?? false;
              bool initialMenstruationRecorded = _selectedMenstruationDays.contains(selectedDay);

              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '날짜: ${selectedDay.year}-${selectedDay.month}-${selectedDay.day}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('영양제 복용', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: initialSupplementTaken,
                          onChanged: (value) {
                            setModalState(() {
                              initialSupplementTaken = value;
                              _supplementTaken[selectedDay] = value;
                            });
                            print('영양제 복용 상태 변경: $value');
                          },
                        ),
                      ],
                    ),
                    if (_gender != '남성') ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('생리 기록', style: TextStyle(fontSize: 16)),
                          Switch(
                            value: initialMenstruationRecorded,
                            onChanged: (value) {
                              setModalState(() {
                                initialMenstruationRecorded = value;
                                if (value) {
                                  _selectedMenstruationDays.add(selectedDay);
                                } else {
                                  _selectedMenstruationDays.remove(selectedDay);
                                }
                              });
                              print('_selectedMenstruationDays after update: $_selectedMenstruationDays');
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveData();
                        Navigator.pop(context); // 서랍 닫기
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
