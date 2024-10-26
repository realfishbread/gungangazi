import 'package:dio/dio.dart';
import '../dto/user_dto.dart';
import '../services/dio_service.dart';

class UserRepository {
  final Dio _dio;

  // 생성자에서 DioService를 통해 Dio 인스턴스를 가져옴
  UserRepository({String? token}) : _dio = DioService().getDio();  // 회원가입 시에는 토큰 필요 없음

  // 서버에 회원가입 요청을 보내고, 성공하면 토큰을 반환
  Future<String?> registerUser(UserDTO user) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        // 서버에서 받은 토큰 반환 (예: response.data에 토큰이 있다고 가정)
        return response.data['token'];  // 토큰이 여기에 저장되어 있다고 가정
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