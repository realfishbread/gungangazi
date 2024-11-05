import '../../services/dio_service.dart';
import '../../dto/userHealth/water_dto.dart';
import '../../services/TokenService.dart'; // TokenService 추가
import 'package:dio/dio.dart';


class WaterRepository {
  final DioService dioService;
  final TokenService tokenService = TokenService(); // TokenService 인스턴스 생성

  WaterRepository({required this.dioService});

  // 물 섭취 기록 데이터 불러오기
  Future<Map<String, int>> fetchWaterIntake() async {
    try {
      // 토큰 가져오기
      String? token = await tokenService.getToken();
      
      final response = await dioService.getDio().get(
        '/waterIntake',
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
      
      await dioService.getDio().post(
        '/saveWaterIntake',
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
