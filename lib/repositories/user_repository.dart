import 'package:dio/dio.dart';
import '../dto/user_dto.dart';

class UserRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://gungangazi.site/api',  // API 기본 URL
    connectTimeout: const Duration(seconds: 5000),    // 연결 타임아웃 설정
    receiveTimeout: const Duration(seconds: 3000),    // 응답 타임아웃 설정
    headers: {'Content-Type': 'application/json; charset=UTF-8'}, // 기본 헤더 설정
  )); 
    // Dio 인스턴스 생성 시에 로그 인터셉터 추가
    UserRepository() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }


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