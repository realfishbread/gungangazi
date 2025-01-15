import 'package:dio/dio.dart';
import '../dto/login_dto.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart'; // TokenService를 임포트
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In 패키지 추가
import 'dart:convert';

class AuthRepository {
  final Dio _dio;
  final TokenService _tokenService = TokenService(); // TokenService 인스턴스 생성
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn 인스턴스 생성

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

  
}
