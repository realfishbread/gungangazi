import 'package:dio/dio.dart';
import '../../dto/auth/user_dto.dart';
import '../../core_services/dio_service.dart';


class UserRepository {
  final Dio _dio;

  // 생성자에서 DioService를 통해 Dio 인스턴스를 가져옴
  UserRepository({String? token}) : _dio = DioService(token: token).getDio();  // 회원가입 시에는 토큰 필요 없음

  // 서버에 회원가입 요청을 보내고, 성공하면 토큰을 반환
  Future<Map<String, String>?> registerUser(UserDTO user) async {
    try {
      // 전송할 데이터를 JSON 형태로 출력
      print('전송할 데이터: ${user.toJson()}');
      final response = await _dio.post(
        '/signup',
        data: user.toJson(),
      );

      print('응답 데이터: ${response.data}');


      if (response.statusCode == 200 || response.statusCode == 201) {  
        final responseData = response.data;
        return {
        'message': responseData['message'],
        'token': responseData['token'],
          };  
      } else {
        print('회원가입 실패: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      final errorMessage = (e.response?.data is Map)
          ? (e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.')
          : '알 수 없는 오류가 발생했습니다.';
      print('회원가입 오류: $errorMessage (status: ${e.response?.statusCode})');
      return {'message': errorMessage, 'token': ''};
    }
  }
  
   Future<String> sendEmailVerification(String email) async {
  try {
    final response = await _dio.post(
      '/request-email-verification',
      data: {'email': email},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200) {
      return response.data['message'] ?? '이메일 인증 성공';
    } else {
      return response.data['error'] ?? '이메일 인증 실패';
    }
  } catch (e) {
    print('Error: ${e.toString()}'); // 로그 추가
    return '서버와의 연결에 실패했습니다: ${e.toString()}';
  }
}

     // 이메일 인증 코드 검증 요청
  Future<String> verifyEmailCode(String email, String token) async {
  try {
    final response = await _dio.post(
      '/verify-code',
      data: {
        'email': email,
        'token': token,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['message'] ?? '이메일 인증이 완료되었습니다.';
    } else {
      return '서버 응답 오류: ${response.statusCode}';
    }
  } on DioException catch (e) {
    print('Dio Exception: ${e.response?.data}');
    return '서버 요청 실패: ${e.message}';
  }
}


 

}