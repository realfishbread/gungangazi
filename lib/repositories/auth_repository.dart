// repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../dto/login_dto.dart';
import '../services/dio_service.dart';  // DioService 임포트

class AuthRepository {
  final Dio _dio;

  // 생성자에서 DioService를 사용하여 Dio 인스턴스를 가져옴
  AuthRepository() : _dio = DioService().getDio();

  // 로그인 API 호출
  Future<LoginResponseDto?> login(LoginRequestDto loginRequest) async {
    try {
      Response response = await _dio.post(
        '/login',  // 'baseUrl'은 DioService에 이미 설정되어 있으므로 상대 경로만 사용
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponseDto.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      print('로그인 오류: ${e.message}');
      return null;
    }
  }
}