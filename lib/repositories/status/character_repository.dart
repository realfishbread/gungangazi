import 'package:gungangazi/core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../../screen/character/PopupHandler.dart';
import 'package:dio/dio.dart';

class CharacterRepository {
   final TokenService _tokenService = TokenService();
   final DioService dioService = DioService();
   late PopupHandler _popupHandler;
   final Dio _dio;
   

  CharacterRepository() : _dio = DioService().getDio();

  Future<void> saveStatusToServer() async {
    try {
      String? username = await TokenService().getUsername();
      String? jwtToken = await TokenService().getToken(); // 토큰 가져오기

      // username이 이메일이면 변환
      if (username != null && username.contains("@")) {
        username = await fetchUsernameFromServer(username);
      }

      await _dio.post(
        '/character/status',
        data: {
          'username': username,
          'water_level': _popupHandler.waterLevel,
          'meal_level': _popupHandler.mealLevel,
          'sleep_level': _popupHandler.sleepLevel,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken', // JWT 토큰 헤더 추가
          },
        ),
      );

      print('Status saved to server successfully');
    } catch (e) {
      print('Failed to save status to server: $e');
    }
  }

  /// 서버에서 현재 상태 불러오기
Future<void> loadStatusFromServer() async {
  try {
    String? username = await TokenService().getUsername();
    String? jwtToken = await TokenService().getToken(); // 토큰 가져오기

    final response = await DioService().getDio().get(
      '/character/status',
      queryParameters: {
        'username': username,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $jwtToken', // JWT 토큰 헤더 추가
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      _popupHandler.waterLevel = data['water_level'] ?? 100;
      _popupHandler.mealLevel = data['meal_level'] ?? 100;
      _popupHandler.sleepLevel = data['sleep_level'] ?? 100;
      _popupHandler.setBodyPartStatus();
      _popupHandler.startImageAnimation(); // 상태 업데이트 후 애니메이션 재시작
      print('Status loaded from server successfully');
    }
  } catch (e) {
    print('Failed to load status from server: $e');
  }
}


  Future<String> fetchUsernameFromServer(String email) async {
  try {
    final response = await _dio.get(
      '/getUsernameByEmail',
      queryParameters: {'email': email},
    );
    return response.data['username'];
  } catch (e) {
    print("❌ Error fetching username: $e");
    return email; // 오류 시 기존 이메일 유지
  }
}
}