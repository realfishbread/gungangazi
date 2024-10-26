// repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../dto/login_dto.dart';

class AuthRepository {
  final Dio _dio = Dio();

  // 로그인 API 호출
  Future<LoginResponseDto?> login(LoginRequestDto loginRequest) async {
    try {
      Response response = await _dio.post(
        'https://gungangazi.site/api/login',
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
