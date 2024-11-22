import '../../services/dio_service.dart';
import '../../dto/userHealth/brush_history.dart';
import '../../services/TokenService.dart';
import 'package:dio/dio.dart';

class ToothRepository {
  final DioService dioService;
  final TokenService tokenService;

  ToothRepository({required this.dioService, required this.tokenService});

  // 양치 기록 데이터 불러오기
  Future<List<BrushHistoryDTO>> fetchBrushHistory() async {
    try {
      // 토큰과 사용자 이름을 가져오기
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();
      
      final response = await dioService.getDio().get(
        '/brushHistory/$username',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      List<BrushHistoryDTO> brushHistoryList = (response.data as List)
          .map((json) => BrushHistoryDTO.fromJson(json))
          .toList();
      return brushHistoryList;
    } catch (e) {
      print("양치 기록 불러오기 실패: $e");
      return [];
    }
  }

  // 양치 기록 데이터 저장
  Future<void> saveBrushData(BrushHistoryDTO data) async {
    try {
      // 토큰과 사용자 이름을 가져오기
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();

      await dioService.getDio().post(
        '/brushHistory/$username/save',
        data: data.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print("양치 데이터가 성공적으로 저장되었습니다.");
    } catch (e) {
      print("양치 데이터 저장 에러: $e");
    }
  }

  Future<void> deleteBrushHistory(String date) async {
    try {
      String? token = await tokenService.getToken();
      await dioService.delete(
        '/brushHistory/$date', // 서버의 삭제 API 엔드포인트
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      throw Exception('양치 기록 삭제에 실패했습니다: $e');
    }
  }
}
