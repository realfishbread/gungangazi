// user_dto.dart
class UserDTO {
  final String username;
  final String email;
  final String realname;
  final String password;
  final String gender; 


  UserDTO({
    required this.username,
    required this.email,
    required this.realname,
    required this.password,
    required this.gender,
  });

  // DTO를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'realname': realname,
      'password': password,
      'gender': gender, // 성별 필드 포함
    };
  }
}
