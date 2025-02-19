import '../../core_services/dio_service.dart';
import '../../dto/userHealth/water_dto.dart';
import '../../../core_services/token_service.dart'; // TokenService 추가
import 'package:dio/dio.dart';

class WaterRepository {
  final DioService dioService;
  final TokenService tokenService; // TokenService 인스턴스 필드 추가

  WaterRepository({required this.dioService, required this.tokenService});

  // 물 섭취 기록 데이터 불러오기
  Future<Map<String, int>> fetchWaterIntake() async {
    try {
      // 토큰 가져오기
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();
      
      final response = await dioService.getDio().get(
        '/waterIntake/$username',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      Map<String, int> waterIntakeMap = Map.fromIterable(
        response.data as List,
        key: (item) => item['date'],
        value: (item) => item['amount'],
      );
      return waterIntakeMap;
    } catch (e) {
      print("물 섭취 기록 불러오기 실패: $e");
      return {};
    }
  }

  // 물 섭취 기록 저장하기
  Future<void> saveWaterIntake(Map<String, int> waterIntake) async {
    try {
      // 토큰 가져오기
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();

      if (username == null) {
        throw Exception("Username is missing");
      }

      await dioService.getDio().post(
        '/waterIntake/$username/save', // username을 URL에 포함
        data: waterIntake.entries
            .map((entry) => {'date': entry.key, 'amount': entry.value})
            .toList(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print("물 섭취 데이터 저장 성공");
    } catch (e) {
      print("물 섭취 데이터 저장 실패: $e");
    }
  }
}
