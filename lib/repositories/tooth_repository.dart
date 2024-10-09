// repositories/tooth_repository.dart
import '../dto/brush_history.dart';
import '../services/tooth_service.dart';

class ToothRepository {
  final ToothService toothService = ToothService();

  // 양치 기록 가져오기
  Future<List<BrushHistoryDTO>> fetchBrushHistory() async {
    final response = await toothService.getBrushHistory();
    List data = response.data as List;
    return data.map((json) => BrushHistoryDTO.fromJson(json)).toList();
  }

  // 양치 기록 저장하기
  Future<void> saveBrushData(BrushHistoryDTO brushData) async {
    final data = brushData.toJson();
    await toothService.postBrushData(data);
  }
}
