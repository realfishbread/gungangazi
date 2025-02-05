class ProfileDto {
  final String? username;
  final String? realname;
  final String? email;
  final String? height;
  final String? weight;
  final String? gender;
  final String? profile_image;
  final String? age; // 여전히 String으로 유지
  final bool? is_google_user; // 추가

  ProfileDto({
    this.username,
    this.realname,
    this.email,
    this.height,
    this.weight,
    this.gender,
    this.profile_image,
    this.age,
    this.is_google_user,
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
      is_google_user: json['is_google_user'] as bool?,
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
      'is_google_user': is_google_user,
    };
  }

  
}
