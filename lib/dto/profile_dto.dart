// models/profile_dto.dart
class ProfileDto {
  final String username;
  final String realname;
  final String email;
  final String height;
  final String weight;
  final String gender;

  ProfileDto({
    required this.username,
    required this.realname,
    required this.email,
    required this.height,
    required this.weight,
    required this.gender,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      username: json['username'],
      realname: json['realname'],
      email: json['email'],
      height: json['height'],
      weight: json['weight'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'realname': realname,
      'email': email,
      'height': height,
      'weight': weight,
      'gender': gender,
    };
  }
}
