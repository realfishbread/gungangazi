// user_repository.dart
import 'package:dio/dio.dart';
import '../dto/user_dto.dart';

class UserRepository {
  final Dio _dio = Dio();

  // 서버의 회원가입 API URL
  final String _signupUrl = 'https://gungangazi.site/api/signup';

  Future<void> registerUser(UserDTO user) async {
    try {
      // POST 요청으로 회원가입 정보를 서버에 전송
      final response = await _dio.post(
        _signupUrl,
        data: user.toJson(),
      );

      // 서버 응답 처리
      if (response.statusCode == 200) {
        print('회원가입 성공: ${response.data}');
      } else {
        print('회원가입 실패: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
    }
  }
}
