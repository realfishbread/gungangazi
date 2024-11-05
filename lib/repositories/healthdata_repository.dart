import '../dto/user_daily.dart';
import '../services/dio_service.dart';

class HealthDataService {
  final DioService dioService;

  HealthDataService({required this.dioService});

  // 수면 데이터 불러오기
  Future<List<SleepDataDto>> fetchSleepData() async {
    try {
      final response = await dioService.getDio().get('/sleepData');
      List<SleepDataDto> sleepDataList = (response.data as List)
          .map((json) => SleepDataDto.fromJson(json))
          .toList();
      return sleepDataList;
    } catch (e) {
      print("수면 데이터 불러오기 실패: $e");
      return [];
    }
  }

  // 식단 데이터 불러오기
  Future<List<DietDataDto>> fetchDietData() async {
    try {
      final response = await dioService.getDio().get('/dietData');
      List<DietDataDto> dietDataList = (response.data as List)
          .map((json) => DietDataDto.fromJson(json))
          .toList();
      return dietDataList;
    } catch (e) {
      print("식단 데이터 불러오기 실패: $e");
      return [];
    }
  }

  // 물 섭취 데이터 불러오기
  Future<List<WaterDataDto>> fetchWaterData() async {
    try {
      final response = await dioService.getDio().get('/waterData');
      List<WaterDataDto> waterDataList = (response.data as List)
          .map((json) => WaterDataDto.fromJson(json))
          .toList();
      return waterDataList;
    } catch (e) {
      print("수분 섭취 데이터 불러오기 실패: $e");
      return [];
    }
  }

  // 수면 데이터 저장
  Future<void> saveSleepData(List<SleepDataDto> data) async {
    try {
      final response = await dioService.getDio().post('/saveSleepData', data: data.map((e) => e.toJson()).toList());
      if (response.statusCode == 200) {
        print("수면 데이터가 성공적으로 저장되었습니다.");
      } else {
        print("수면 데이터 저장 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("수면 데이터 저장 에러: $e");
    }
  }
}
