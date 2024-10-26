import 'package:shared_preferences/shared_preferences.dart';

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
    return prefs.getString(_tokenKey);  // 저장된 토큰 불러오기
  }

  // 토큰 삭제 함수 (로그아웃 시 사용)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);  // 토큰 삭제
  }
}
