import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // 날짜 형식을 위한 패키지

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  _BloodPressurePageState createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  // 데이터를 저장할 Map (날짜를 키로 사용)
  final Map<String, List<Map<String, String>>> _groupedRecords = {};

  void _submitData() {
    final String systolic = _systolicController.text;
    final String diastolic = _diastolicController.text;
    final String heartRate = _heartRateController.text;
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 현재 날짜

    if (systolic.isNotEmpty && diastolic.isNotEmpty && heartRate.isNotEmpty) {
      // 날짜별로 데이터를 저장
      setState(() {
        if (_groupedRecords.containsKey(currentDate)) {
          _groupedRecords[currentDate]!.add({
            'systolic': systolic,
            'diastolic': diastolic,
            'heartRate': heartRate,
          });
        } else {
          _groupedRecords[currentDate] = [
            {
              'systolic': systolic,
              'diastolic': diastolic,
              'heartRate': heartRate,
            }
          ];
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
              child: const Text('제출'),
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
                            '최고 혈압: ${record['systolic']} / 최저 혈압: ${record['diastolic']}'),
                        subtitle: Text('심박수: ${record['heartRate']} bpm'),
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
