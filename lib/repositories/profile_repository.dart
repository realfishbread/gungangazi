import 'package:dio/dio.dart';
import '../dto/profile_dto.dart';
import '../services/dio_service.dart'; 
import '../services/TokenService.dart';

class ProfileRepository {
  final Dio _dio;
  final TokenService tokenService; // TokenService 인스턴스 추가

  ProfileRepository({required DioService dioService, required this.tokenService}) 
      : _dio = dioService.getDio(); // DioService에서 Dio 객체를 가져옵니다.

  // 프로필 정보 가져오기
  Future<ProfileDto?> fetchProfile(String username) async {
    try {
      // 토큰을 가져와 Authorization 헤더에 추가
      String? token = await tokenService.getToken();
      Response response = await _dio.get(
        '/profile',
        options: Options(headers: {"Authorization": "Bearer $token"})
      );

      if (response.statusCode == 200) {
        return ProfileDto.fromJson(response.data);
      } else {
        print('프로필 로드에 실패했습니다. 상태 코드: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('에러 발생: $e');
      return null;
    }
  }

  // 프로필 정보 업데이트
  Future<bool> updateProfile(String username, Map<String, dynamic> updatedData) async {
    try {
      String? token = await tokenService.getToken();
      Response response = await _dio.put(
        '/$username/update',
        data: updatedData, // updatedData가 Map 형식으로 전송됩니다
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('에러 발생: $e');
      return false;
    }
  }

  Future<bool> linkGoogleAccount(String? idToken, String? accessToken) async {
    try {
      final response = await _dio.post('/api/auth/link-google', data: {
        'idToken': idToken,
        'accessToken': accessToken,
      });

      return response.statusCode == 200;
    } catch (e) {
      print("Google 계정 연동 중 오류: $e");
      return false;
    }
  }

}

