import 'package:dio/dio.dart';
import '../../dto/auth/login_dto.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart'; // TokenService를 임포트
import '../../core_services/google_auth_services.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


class AuthRepository {
  final Dio _dio;
  final TokenService _tokenService = TokenService(); // TokenService 인스턴스 생성
  final GoogleAuthService _googleAuthService = GoogleAuthService();





  // 생성자에서 DioService를 사용하여 Dio 인스턴스를 가져옴
  AuthRepository() : _dio = DioService().getDio();

  // 로그인 API 호출
 Future<LoginResponseDto?> login(LoginRequestDto loginRequest) async {
    try {
      Response response = await _dio.post(
        '/login',
        data: loginRequest.toJson(), // JSON 형태로 변환된 데이터를 전송
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


  /// ✅ Google 로그인 (Auth Code를 서버에 전송)
  Future<Map<String, dynamic>?> googleLogin() async {
    try {
      // ✅ Auth Code 가져오기
      final String? authCode = await _googleAuthService.signInWithGoogle();
      if (authCode == null) {
        print('❌ Auth Code가 null이므로 서버 요청을 보낼 수 없습니다.');
        return null;
      }

      // ✅ 서버에 Auth Code 전송
      final response = await _dio.post(
        '/api/auth/google-login',
        data: jsonEncode({'authCode': authCode}), // JSON 바디에 Auth Code 포함
        options: Options(headers: {
          'Content-Type': 'application/json',
          'clientType': Platform.isAndroid ? 'android' : 'web', // ✅ 클라이언트 타입 추가
          // 'Authorization': 'Bearer $authCode', ❌ 이거 필요 없음 (Auth Code는 인증이 아니라 교환용임)
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = response.data;
        print('✅ 서버 응답: $responseBody');

        // ✅ 토큰 저장
        if (responseBody.containsKey('token')) {
          await _tokenService.saveToken(responseBody['token']);
        }

        return responseBody;
      } else {
        print('❌ Google 로그인 실패: 서버 오류 (${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('❌ 서버 요청 중 오류 발생: $e');
      return null;
    }
  }
 

  
}
