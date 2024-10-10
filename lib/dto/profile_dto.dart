// models/profile_dto.dart
class ProfileDto {
  final String userId;
  final String name;
  final String email;
  final String height;
  final String weight;
  final String gender;

  ProfileDto({
    required this.userId,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.gender,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      height: json['height'],
      weight: json['weight'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'gender': gender,
    };
  }
}
