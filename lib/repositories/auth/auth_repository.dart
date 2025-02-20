import 'package:dio/dio.dart';
import '../../dto/auth/login_dto.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart'; // TokenService를 임포트
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In 패키지 추가
import 'dart:convert';
import '../../core_services/google_auth_services.dart';

class AuthRepository {
  final Dio _dio;
  final TokenService _tokenService = TokenService(); // TokenService 인스턴스 생성
  final GoogleAuthService _googleAuthService = GoogleAuthService();





  // 생성자에서 DioService를 사용하여 Dio 인스턴스를 가져옴
  AuthRepository() : _dio = DioService().getDio();

  // 로그인 API 호출
  Future<LoginResponseDto?> login(LoginRequestDto loginRequest) async {

    String? accessToken = await _googleAuthService.signInWithGoogle();
    try {
      final response = await _dio.post(
          '/api/auth/google-login',
          data: {'accessToken': accessToken},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

      // 응답 데이터를 JSON으로 변환하여 출력
      print('로그인 응답: ${response.data}'); // 응답 데이터 출력

      if (response.statusCode == 200) {
        // 응답 데이터에서 토큰 추출
        String token = response.data['token'];

        // TokenService를 통해 토큰 저장
        await _tokenService.saveToken(token);
        print("토큰 저장 완료: $token");

        return LoginResponseDto.fromJson(response.data);
      } else {
        print('로그인 실패: ${response.statusCode} - ${response.data}');
        return null; // 로그인 실패
      }
    } on DioException catch (e) {
      print('로그인 오류: ${e.response?.data ?? e.message}');
      return null; // 예외 발생 시 null 반환
    }
  }



  Future<Map<String, dynamic>?> googleLogin() async {


    try {
      final accessToken = await _googleAuthService.signInWithGoogle();
      final response = await _dio.post(
        '/api/auth/google-login',
        data: {'accessToken': accessToken},
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = response.data;
        print('서버 응답: $responseBody');

        // 토큰 저장
        await _tokenService.saveToken(responseBody['token']);

        return responseBody;
      } else {
        print('Google 로그인 실패: 서버 오류 (${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('서버 요청 중 오류 발생: $e');
      return null;
    }
  }
 

  
}
