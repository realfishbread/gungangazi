import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import 'repositories/userHealth/tooth_repository.dart';
import 'dto/userHealth/brush_history.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'PopupHandler.dart';

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

  late Future<List<BrushHistoryDTO>> _brushHistory;
  final _formKey = GlobalKey<FormState>();
  String? _selectedDate;
  int _duration = 0;
  bool _flossed = false;
  bool _currentTooth=false;

  @override
  void initState() {
    super.initState();
    _brushHistory = toothRepository.fetchBrushHistory();
    _currentTooth=false;
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

  // 양치 기록 저장 메서드
  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? username = await toothRepository.tokenService.getUsername(); // toothRepository에서 호출
      BrushHistoryDTO newBrushData = BrushHistoryDTO(
        date: _selectedDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()), // 기본값 제공,
        duration: _duration > 0 ? _duration : 1, // 기본값 제공
        flossed: _flossed,
        username: username,
      );

      await toothRepository.saveBrushData(newBrushData);

      setState(() {
        _brushHistory = toothRepository.fetchBrushHistory();
        _currentTooth=true;
      });

      _formKey.currentState!.reset();
      _selectedDate = null;
      _duration = 0;
      _flossed = false;
    }
  }



  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // 물 상태가 증가했는지 확인하고 애니메이션 실행
      if (_currentTooth=true) {
        widget.popupHandler.triggerAnimation('brush', delayMilliseconds: 1000);
      } else {
        print("No significant tooth level change, no animation triggered.");
      }

      // 뒤로가기 동작 허용
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
            // 양치 기록 리스트
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
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final history = snapshot.data![index];
                        return ListTile(
                          title: Text('날짜: ${history.date}'),
                          subtitle: Text('시간: ${history.duration}분, 치실 사용: ${history.flossed ? "O" : "X"}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // 양치 기록 추가 폼
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // 날짜 선택 버튼
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



