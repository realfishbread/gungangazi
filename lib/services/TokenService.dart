import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart'; // jwt_decode 패키지를 임포트

class TokenService {
  static const String _tokenKey = 'auth_token';  // 토큰 저장을 위한 키

  // 토큰 저장 함수
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);  // 토큰을 SharedPreferences에 저장
  }

  // 토큰 불러오는 함수
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    print("토큰 값: $token"); // 토큰 값 출력
    return token;
  }

  // 토큰 삭제 함수 (로그아웃 시 사용)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);  // 토큰 삭제
  }

  // 토큰에서 username을 추출하는 함수
  Future<String?> getUsername() async {
    String? token = await getToken(); // 토큰을 가져옵니다.
    if (token != null) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token); // 토큰을 디코딩하여 페이로드를 가져옵니다.
        return payload['username']; // 페이로드에서 username을 추출합니다.
      } catch (e) {
        print('토큰 디코딩 중 에러 발생: $e');
        return null;
      }
    }
    return null; // 토큰이 없을 경우 null 반환
  }
}