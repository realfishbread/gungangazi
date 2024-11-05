import '../services/dio_service.dart';
import '../dto/brush_history.dart';

class ToothRepository {
  final DioService dioService;

  ToothRepository({required this.dioService});

  // 양치 기록 데이터 불러오기
  Future<List<BrushHistoryDTO>> fetchBrushHistory() async {
    try {
      final response = await dioService.getDio().get('/brushHistory');
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
      final response = await dioService.getDio().post(
        '/saveBrushData',
        data: data.toJson(),
      );
      if (response.statusCode == 200) {
        print("양치 데이터가 성공적으로 저장되었습니다.");
      } else {
        print("양치 데이터 저장 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("양치 데이터 저장 에러: $e");
    }
  }
}
