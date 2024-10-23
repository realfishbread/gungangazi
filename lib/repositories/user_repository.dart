import 'package:dio/dio.dart';
import '../dto/user_dto.dart';

class UserRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://gungangazi.site/api/users',  // API 기본 URL
    connectTimeout: const Duration(seconds: 5),    // 연결 타임아웃 설정
    receiveTimeout: const Duration(seconds: 3),    // 응답 타임아웃 설정
    headers: {'Content-Type': 'application/json; charset=UTF-8'}, // 기본 헤더 설정
  ));

  Future<void> registerUser(UserDTO user) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'id': user.id,
          'username': user.username,
          'password': user.password,
          'email': user.email,
          'gender': user.gender,
        },
      );

      if (response.statusCode == 200) {
        // 회원가입 성공 처리
        print('회원가입 성공');
      } else {
        // 오류 처리
        print('회원가입 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // DioException을 통해 발생한 오류 처리
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