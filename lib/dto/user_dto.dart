// user_dto.dart
class UserDTO {
  final String username;
  final String email;
  final String id;
  final String password;
  final String gender;

  UserDTO({
    required this.username,
    required this.email,
    required this.id,
    required this.password,
    required this.gender,
  });

  // DTO를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'id': id,
      'password': password,
      'gender': gender,
    };
  }
}
