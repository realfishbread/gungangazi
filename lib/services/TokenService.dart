import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';

  // 토큰 저장 함수
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 토큰 불러오는 함수
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 토큰 삭제 함수 (로그아웃 시 사용)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // 토큰에서 username을 추출하는 함수
  Future<String?> getUsername() async {
    String? token = await getToken();
    if (token != null) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        String? username = payload['sub']; // JWT에서 'sub' 클레임을 username으로 사용
        if (username != null) {
          return username;
        } else {
          print('username 필드를 찾을 수 없습니다.');
        }
      } catch (e) {
        print('토큰 디코딩 중 에러 발생: $e');
      }
    }
    return null;
  }
  Future<String?> getGender() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('gender'); // 저장된 성별 정보 반환
}
}
