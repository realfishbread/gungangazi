class ProfileDto {
  final String? username;
  final String? realname;
  final String? email;
  final String? height;
  final String? weight;
  final String? gender;
  final String? profile_image;
  final String? age; // 여전히 String으로 유지

  ProfileDto({
    this.username,
    this.realname,
    this.email,
    this.height,
    this.weight,
    this.gender,
    this.profile_image,
    this.age,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      username: json['username'] as String?,
      realname: json['realname'] as String?,
      email: json['email'] as String?,
      height: json['height'] as String?,
      weight: json['weight'] as String?,
      gender: json['gender'] as String?,
      profile_image: json['profile_image'] as String?,
      age: json['age'] as String?, // JSON에서 age를 String으로 변환
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
      'profile_image': profile_image,
      'age': age, // String으로 저장
    };
  }

  // String 형태의 age를 int로 변환해주는 유틸리티
  int get ageAsInt => int.tryParse(age ?? '0') ?? 0;

  // age를 업데이트할 수 있는 메서드 추가
  ProfileDto copyWith({
    String? username,
    String? realname,
    String? email,
    String? height,
    String? weight,
    String? gender,
    String? profile_image,
    String? age,
  }) {
    return ProfileDto(
      username: username ?? this.username,
      realname: realname ?? this.realname,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      profile_image: profile_image ?? this.profile_image,
      age: age ?? this.age,
    );
  }
}
