import 'package:dio/dio.dart';
import '../dto/profile_dto.dart';
import '../services/dio_service.dart'; // DioService를 임포트하세요.

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({required DioService dioService}) : _dio = dioService.getDio(); // DioService에서 Dio 객체를 가져옵니다.

  // 프로필 정보 가져오기
  Future<ProfileDto?> fetchProfile(String username) async {
    try {
      Response response = await _dio.get('/profile');
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
  Future<bool> updateProfile(String username, String fieldName, String newValue) async {
    try {
      Response response = await _dio.put(
        '/$username/update',
        data: {fieldName: newValue}, // 서버가 요구하는 형식에 맞는지 확인하세요.
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('에러 발생: $e');
      return false;
    }
  }
}
