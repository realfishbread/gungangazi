// repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../dto/login_dto.dart';

class AuthRepository {
  final Dio _dio = Dio();

  // 로그인 API 호출
  Future<LoginResponseDto?> login(LoginRequestDto loginRequest) async {
    try {
      Response response = await _dio.post(
        'https://15.164.140.55/api/login',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponseDto.fromJson(response.data);
      } else {
        return null;
      }
    } on DioError catch (e) {
      print('Login error: ${e.message}');
      return null;
    }
  }
}
