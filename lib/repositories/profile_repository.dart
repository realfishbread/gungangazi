// repositories/profile_repository.dart
import 'package:dio/dio.dart';
import '../dto/profile_dto.dart';

class ProfileRepository {
  final Dio _dio = Dio();

  // 프로필 정보 가져오기
  Future<ProfileDto?> fetchProfile() async {
    try {
      Response response = await _dio.get('https://15.164.140.55/api/User');

      if (response.statusCode == 200) {
        return ProfileDto.fromJson(response.data);
      } else {
        print('Failed to load profile. Status code: ${response.statusCode}');
        return null;
      }
    } on DioError catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // 프로필 정보 업데이트
  Future<bool> updateProfile(String fieldName, String newValue) async {
    try {
      Response response = await _dio.put(
        'http://15.164.140.55/api/profile/update',
        data: {fieldName: newValue},
      );

      return response.statusCode == 200;
    } on DioError catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }
}
