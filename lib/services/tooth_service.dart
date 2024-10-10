// services/api_service.dart
import 'package:dio/dio.dart';
import 'dio_service.dart';

class ToothService {
  final DioService _dioService = DioService();

  // 양치 기록 가져오기 (GET)
  Future<Response> getBrushHistory() async {
    try {
      Dio dio = _dioService.getDio();
      return await dio.get('/brush/history');
    } catch (e) {
      throw Exception('Failed to load brush history');
    }
  }

  // 양치 기록 저장하기 (POST)
  Future<Response> postBrushData(Map<String, dynamic> data) async {
    try {
      Dio dio = _dioService.getDio();
      return await dio.post('/brush/save', data: data);
    } catch (e) {
      throw Exception('Failed to save brush data');
    }
  }
}
