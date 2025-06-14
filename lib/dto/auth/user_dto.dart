// user_dto.dart
class UserDTO {
  final String username;
  final String email;
  final String realname;
  final String gender;
  // TODO: password는 서버 응답에 포함되지 않도록 분리 예정 (보안상 필요)
// 개발 중 임시로 유지
final String password;

  UserDTO({
    required this.username,
    required this.email,
    required this.realname,
    required this.gender,
    required this.password
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      realname: json['realname'] ?? '',
      gender: json['gender'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'realname': realname,
      'gender': gender,
      'password': password,
    };
  }
}
