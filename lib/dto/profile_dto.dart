import 'dart:convert';
class ProfileDto {
  final String? username;
  final String? realname;
  final String? email;
  final String? height;
  final String? weight;
  final String? gender;
  final String? profileImage;

  ProfileDto({
    this.username,
    this.realname,
    this.email,
    this.height,
    this.weight,
    this.gender,
    this.profileImage,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      username: json['username'],
      realname: json['realname'],
      email: json['email'],
      height: json['height'],
      weight: json['weight'],
      gender: json['gender'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (realname != null) data['realname'] = realname;
    if (email != null) data['email'] = email;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (gender != null) data['gender'] = gender;
    if (profileImage != null) data['profileImage'] = profileImage;
    return data;
  }
}
