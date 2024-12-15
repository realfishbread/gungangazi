import 'package:dio/dio.dart';
import '../dto/user_dto.dart';
import '../services/dio_service.dart';


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

      
      // 응답 데이터 출력
      print('응답 데이터: ${response.data}');


      if (response.statusCode == 200 || response.statusCode == 201) {  
        final responseData = response.data;
        return {
        'message': responseData['message'],
        'token': responseData['token'],
          };  // "회원가입 성공" 또는 "아이디가 이미 존재합니다." 등의 메시지 반환
      } else {
        print('회원가입 실패: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
      print('회원가입 오류: $errorMessage');
      return errorMessage;  // 오류 메시지 반환
    }
  }
  
   Future<String> sendEmailVerification(String email) async {
    
    try {
      // POST 요청으로 이메일 데이터를 서버에 전송
      final response = await _dio.post(
        '/verify-email',
        data: {'email': email}, // JSON 데이터
        options: Options(
          headers: {'Content-Type': 'application/json'}, // 헤더 설정
        ),
      );

      if (response.statusCode == 200) {
        return response.data['message']; // 성공 메시지 반환
      } else {
        return response.data['error'] ?? '이메일 인증 실패'; // 실패 메시지 반환
      }
    } catch (e) {
      throw Exception('Error sending email verification: $e');
    }
  }

}