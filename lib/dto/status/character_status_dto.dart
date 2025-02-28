class StatusDto {
  final String? username;
  final int waterLevel;
  final int mealLevel;
  final int sleepLevel;

  StatusDto({
    required this.username,
    required this.waterLevel,
    required this.mealLevel,
    required this.sleepLevel
  });

  factory StatusDto.fromJson(Map<String?, dynamic> json) {
    return StatusDto(
      waterLevel: json['water_level'],
      mealLevel: json['meal_level'],
      sleepLevel: json['sleep_level'],
      username: json['username']
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      'water_level': waterLevel,
      'meal_level': mealLevel,
      'sleep_level': sleepLevel,
      'username': username
    };
  }
}
