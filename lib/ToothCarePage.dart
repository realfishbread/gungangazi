import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import '../repositories/tooth_repository.dart';
import '../dto/brush_history.dart';

class ToothCarePage extends StatefulWidget {
  @override
  _ToothCarePageState createState() => _ToothCarePageState();
}

class _ToothCarePageState extends State<ToothCarePage> {
  final ToothRepository toothRepository = ToothRepository();

  late Future<List<BrushHistoryDTO>> _brushHistory;

  final _formKey = GlobalKey<FormState>();
  String? _selectedDate;
  int _duration = 0;
  bool _flossed = false;

  @override
  void initState() {
    super.initState();
    _brushHistory = toothRepository.fetchBrushHistory();
  }

  // 날짜 선택 메서드
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

      BrushHistoryDTO newBrushData = BrushHistoryDTO(
        date: _selectedDate ?? '', // 선택된 날짜를 저장
        duration: _duration,
        flossed: _flossed,
      );

      await toothRepository.saveBrushData(newBrushData);

      // 데이터를 저장한 후 리스트를 새로 고침
      setState(() {
        _brushHistory = toothRepository.fetchBrushHistory();
      });

      // 입력 폼 초기화
      _formKey.currentState!.reset();
      _selectedDate = null;
      _duration = 0;
      _flossed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이빨 관리'),
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
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('기록이 없습니다.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final history = snapshot.data![index];
                        return ListTile(
                          title: Text('날짜: ${history.date}'),
                          subtitle: Text('시간: ${history.duration}분, 치실 사용: ${history.flossed ? "네" : "아니오"}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16),

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
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    decoration: InputDecoration(labelText: '양치 시간(분)'),
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
                    title: Text('치실 사용'),
                    value: _flossed,
                    onChanged: (value) => setState(() => _flossed = value),
                  ),
                  ElevatedButton(
                    onPressed: _saveData,
                    child: Text('저장'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
