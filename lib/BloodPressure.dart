import 'package:flutter/material.dart';
import 'package:gungangazi/services/TokenService.dart';
import 'package:intl/intl.dart';
import '../../dto/userHealth/blood_pressure_dto.dart';
import '../../repositories/userHealth/blood_pressure_repository.dart';
import '../../services/dio_service.dart';

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  _BloodPressurePageState createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final Map<String, List<BloodPressureDTO>> _groupedRecords = {};
  final BloodPressureRepository bloodPressureRepository = BloodPressureRepository(
    dioService: DioService(),
    tokenService: TokenService(),
  );

  @override
  void initState() {
    super.initState();
    _loadDataFromServer();
  }

  // 서버에서 데이터를 불러오는 메서드
  Future<void> _loadDataFromServer() async {
    List<BloodPressureDTO> records = await bloodPressureRepository.fetchBloodPressureDataFromDatabase();
    setState(() {
      for (var record in records) {
        if (_groupedRecords.containsKey(record.date)) {
          _groupedRecords[record.date]!.add(record);
        } else {
          _groupedRecords[record.date] = [record];
        }
      }
    });
  }

  // 데이터를 제출하고 서버에 저장하는 메서드
  Future<void> _submitData() async {
    final String systolic = _systolicController.text;
    final String diastolic = _diastolicController.text;
    final String heartRate = _heartRateController.text;
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? username = await TokenService().getUsername(); // username 가져오기

    if (systolic.isNotEmpty && diastolic.isNotEmpty && heartRate.isNotEmpty && username != null) {
      final newRecord = BloodPressureDTO(
        systolic: systolic,
        diastolic: diastolic,
        heart_rate: heartRate,
        date: currentDate,
        username: username,
      );

      // 서버에 데이터 저장
      await bloodPressureRepository.saveBloodPressureDataToDatabase(newRecord);

      // UI 업데이트
      setState(() {
        if (_groupedRecords.containsKey(currentDate)) {
          _groupedRecords[currentDate]!.add(newRecord);
        } else {
          _groupedRecords[currentDate] = [newRecord];
        }
      });

      // 입력 필드 초기화
      _systolicController.clear();
      _diastolicController.clear();
      _heartRateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('데이터가 저장되었습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 값을 입력해주세요.')),
      );
    }
  }

  // 데이터를 삭제하는 메서드
  Future<void> _deleteData(String date, BloodPressureDTO record) async {
    await bloodPressureRepository.deleteBloodPressureDataFromDatabase(record);
    setState(() {
      _groupedRecords[date]?.remove(record);
      if (_groupedRecords[date]?.isEmpty ?? true) {
        _groupedRecords.remove(date);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터가 삭제되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('혈압과 심박수 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _systolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '최고 혈압 (mmHg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diastolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '최저 혈압 (mmHg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heartRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '심박수 (bpm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('저장'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _groupedRecords.isEmpty
                  ? const Center(child: Text('저장된 데이터가 없습니다.'))
                  : ListView(
                      children: _groupedRecords.keys.map((date) {
                        return ExpansionTile(
                          title: Text('날짜: $date'),
                          children: _groupedRecords[date]!.map((record) {
                            return ListTile(
                              title: Text(
                                  '최고 혈압: ${record.systolic} / 최저 혈압: ${record.diastolic}'),
                              subtitle: Text('심박수: ${record.heart_rate} bpm'),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _deleteData(date, record),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }
}
