import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import '../../../repositories/userHealth/tooth_repository.dart';
import '../../../dto/userHealth/brush_history.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../character/popup_handler.dart';
import '../../../repositories/userHealth/sleep_repository.dart'; // SleepRepository 임포트
import '../../../dto/userHealth/sleep_dto.dart'; // SleepDTO 임포트


class ToothCarePage extends StatefulWidget {
  final PopupHandler popupHandler;

  const ToothCarePage({Key? key, required this.popupHandler}) : super(key: key);

  @override
  _ToothCarePageState createState() => _ToothCarePageState();
}

class _ToothCarePageState extends State<ToothCarePage> {
  final ToothRepository toothRepository = ToothRepository(
    dioService: DioService(),
    tokenService: TokenService(),
  );
  final SleepRepository sleepRepository = SleepRepository(
    dioService: DioService(),
    tokenService: TokenService(),
  );
  late Future<List<SleepDto>> _sleepHistory;
  late Future<List<BrushHistoryDTO>> _brushHistory;
  final _formKey = GlobalKey<FormState>();
  String? _selectedDate;
  int _duration = 0;
  bool _flossed = false;
  bool _currentTooth = false;
  DateTime now = DateTime.now();

 


  @override
  void initState() {
    super.initState();
    _brushHistory = toothRepository.fetchBrushHistory();
    _sleepHistory = sleepRepository.fetchSleepDataFromDatabase();
    _currentTooth = false;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? username = await toothRepository.tokenService.getUsername();
      BrushHistoryDTO newBrushData = BrushHistoryDTO(
        date: _selectedDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        duration: _duration > 0 ? _duration : 1,
        flossed: _flossed,
        username: username,
      );

      await toothRepository.saveBrushData(newBrushData);

      setState(() {
        _brushHistory = toothRepository.fetchBrushHistory();
        _currentTooth = true;
      });

      _formKey.currentState!.reset();
      _selectedDate = null;
      _duration = 0;
      _flossed = false;
    }
  }

  Future<void> _checkBrushAndSleep() async {
    List<SleepDto> sleepData = await sleepRepository.fetchSleepDataFromDatabase();
    List<BrushHistoryDTO> brushData = await toothRepository.fetchBrushHistory();

    if (sleepData.isNotEmpty) {
      SleepDto latestSleep = sleepData.last;
      String latestSleepDate = latestSleep.date;

      bool brushed = brushData.any((brush) => brush.date == latestSleepDate);

      bool isNightTime = now.hour >= 22; // 22시(10PM) 이후인지 확인


      if (!brushed) {
        if (isNightTime) {
         await widget.popupHandler.triggerAnimation('0amnobrush', delayMilliseconds: 1000);
        } else {
          await widget.popupHandler.triggerAnimation('nobrush', delayMilliseconds: 1000);
        }
      } else if (_currentTooth == true) { 
        if (isNightTime) {
          await widget.popupHandler.triggerAnimation('0ambrush', delayMilliseconds: 1000);
        } else {
          await widget.popupHandler.triggerAnimation('brush', delayMilliseconds: 1000);
        }
      } else {
        print("No significant tooth level change, no animation triggered.");
      }
    }
  }

  void _deleteBrushHistory(BrushHistoryDTO history) async {
  try {
    if (history.id == null) {
      throw Exception('삭제할 id가 null입니다.');
    }
    await toothRepository.deleteBrushHistory(history.id!); // id를 올바르게 전달
    setState(() {
      _brushHistory = toothRepository.fetchBrushHistory(); // 삭제 후 UI 업데이트
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${history.date} 기록이 삭제되었습니다.')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('기록 삭제 실패: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _checkBrushAndSleep();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('치아 관리'),
          backgroundColor: const Color(0xFFFFF9C4),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<BrushHistoryDTO>>(
                  future: _brushHistory,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('기록이 없습니다.'));
                    } else {
                      return ListView.separated(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final history = snapshot.data![index];
                          return ListTile(
                            title: Text('날짜: ${history.date}'),
                            subtitle: Text('시간: ${history.duration}분, 치실 사용: ${history.flossed ? "O" : "X"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _deleteBrushHistory(history),
                              tooltip: '삭제',
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(), // 구분선 추가
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          _selectedDate == null ? '날짜 선택' : '선택된 날짜: $_selectedDate',
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                        decoration: const InputDecoration(labelText: '양치 시간(분)'),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _duration = int.parse(value!),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '양치 시간을 입력하세요.';
                          }
                          // 숫자인지 확인
                          if (int.tryParse(value) == null) {
                            return '숫자만 입력 가능합니다.';
                          }
                          // 0 이상의 값인지 확인
                          if (int.parse(value) <= 0) {
                            return '양치 시간은 1분 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),
                    SwitchListTile(
                      title: const Text('치실 사용'),
                      value: _flossed,
                      onChanged: (value) => setState(() => _flossed = value),
                    ),
                    ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF9C4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        ),
                      ),
                      child: const Text('저장'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

