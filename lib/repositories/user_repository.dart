import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dto/user_dto.dart';

class UserRepository {
  final String apiUrl = 'https://gungangazi.site/api/signup';  // API 엔드포인트 URL

  Future<void> registerUser(UserDTO user) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': user.name,
        'email': user.email,
        'username': user.id,  // id는 username으로 사용한다고 가정
        'password': user.password,
        'gender': user.gender,
      }),
    );

    if (response.statusCode == 200) {
      // 회원가입 성공 처리
      print('회원가입 성공');
    } else {
      // 오류 처리
      throw Exception('회원가입 실패');
    }
  }
}