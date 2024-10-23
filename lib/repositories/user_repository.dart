import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dto/user_dto.dart';

class UserRepository {
  final String apiUrl = 'https://gungangazi.site/api/users';  // API 엔드포인트 URL

  Future<void> registerUser(UserDTO user) async {
    final response = await http.post(
      Uri.parse('$apiUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': user.id,
        'password': user.password,
        'email': user.email,
        'gender': user.gender,
        'username': user.username,
      }),
    );

    if (response.statusCode == 200) {
      // 회원가입 성공 처리
      print('회원가입 성공');
    } else {
      // 오류 처리
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception(' ${errorResponse['message']}');
    }
  }
}