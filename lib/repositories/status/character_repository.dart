import 'package:gungangazi/core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../../screen/character/popup_handler.dart';
import 'package:dio/dio.dart';
import '../../dto/status/character_status_dto.dart';

class CharacterRepository {
   final TokenService _tokenService = TokenService();
   final DioService dioService = DioService();
   late PopupHandler _popupHandler;
   final Dio _dio;
   

  CharacterRepository() : _dio = DioService().getDio();

    /// 서버에 현재 상태 저장
Future<void> saveStatusToServer(StatusDto statusDto) async {
  try {
    String? jwtToken = await _tokenService.getToken(); // 토큰 가져오기

    await _dio.post(
      '/character/status',
      data: statusDto.toJson(),//데이터 감싸보내지마
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
Future<Map<String, dynamic>?> loadStatusFromServer() async {
  try {
    String? username = await _tokenService.getUsername();
    String? jwtToken = await _tokenService.getToken(); // 토큰 가져오기

    final response = await _dio.get(
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
      Map<String, dynamic> responseData = response.data; // 🔥 응답 데이터 저장

      // 상태 업데이트 및 애니메이션 재시작
      await _popupHandler.stopImageAnimation();
      await _popupHandler.setBodyPartStatus();
      await _popupHandler.startImageAnimation(); // 상태 업데이트 후 애니메이션 재시작

      print('Status loaded from server successfully');
      
      return responseData; // ✅ Map<String, dynamic> 반환
    } else {
      // 서버 응답이 실패한 경우
      print('Failed to load status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // 예외 발생 시 에러 메시지 출력
    print('Failed to load status from server: $e');
    return null;
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