import 'package:dio/dio.dart';
import '../dto/user_dto.dart';
import '../services/dio_service.dart';

class UserRepository {
  final Dio _dio;

  // 생성자에서 DioService를 통해 Dio 인스턴스를 가져옴
  UserRepository({String? token}) : _dio = DioService(token: token).getDio();  // 회원가입 시에는 토큰 필요 없음

  // 서버에 회원가입 요청을 보내고, 성공하면 토큰을 반환
  Future<String?> registerUser(UserDTO user) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: user.toJson(),
      );

      if (response.statusCode == 201) {  // 201 Created 상태 코드 확인
      return response.data['token'];  // 성공 시 반환된 토큰
      } else {
          print('회원가입 실패: ${response.statusCode}');
          return null;
      }
    } on DioException catch (e) {
      print('회원가입 오류: ${e.response?.data}');
      return null;
    }
  }
}