import 'package:dio/dio.dart';
import '../dto/user_dto.dart';
import '../services/dio_service.dart';  // DioService 임포트

class UserRepository {
  final Dio _dio;

  // 생성자에서 DioService를 사용하여 Dio 인스턴스를 가져옴
  UserRepository() : _dio = DioService().getDio();

  Future<void> registerUser(UserDTO user) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        // 회원가입 성공 처리
        print('회원가입 성공');
      } else if (response.statusCode == 400) {
        print('잘못된 요청: ${response.data}');
      } else if (response.statusCode == 500) {
        print('서버 오류: ${response.data}');
      } else {
        // 기타 오류 처리
        print('회원가입 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('서버 응답 오류: ${e.response?.data}');
        throw Exception('회원가입에 실패했습니다: ${e.response?.data['message']}');
      } else {
        print('서버에 연결할 수 없습니다: $e');
        throw Exception('서버에 연결할 수 없습니다.');
      }
    }
  }
}
