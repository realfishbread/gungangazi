class StatusDto {
  final String? username;
  final int water_level;
  final int meal_level;
  final int sleep_level;

  StatusDto({
    required this.username,
    required this.water_level,
    required this.meal_level,
    required this.sleep_level
  });

  factory StatusDto.fromJson(Map<String?, dynamic> json) {
    return StatusDto(
      water_level: json['water_level'],
      meal_level: json['meal_level'],
      sleep_level: json['sleep_level'],
      username: json['username']
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      'water_level': water_level,
      'meal_level': meal_level,
      'sleep_level': sleep_level,
      'username': username
    };
  }
}
