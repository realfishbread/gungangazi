import '../services/health_data_service.dart';
import '../dto/user_daily.dart';
import '../services/dio_service.dart';

class HealthDataRepository {
  final HealthDataService healthDataService;

  HealthDataRepository({required DioService dioService})
      : healthDataService = HealthDataService(dioService: dioService);

  Future<List<SleepDataDto>> getSleepData() async {
    return await healthDataService.fetchSleepData();
  }

  Future<List<DietDataDto>> getDietData() async {
    return await healthDataService.fetchDietData();
  }

  Future<List<WaterDataDto>> getWaterData() async {
    return await healthDataService.fetchWaterData();
  }

  Future<void> saveSleepData(List<SleepDataDto> data) async {
    await healthDataService.saveSleepData(data);
  }
}
