
class SleepDataDto {
  final String day;
  final double hours;

  SleepDataDto({required this.day, required this.hours});

  factory SleepDataDto.fromJson(Map<String, dynamic> json) {
    return SleepDataDto(
      day: json['day'],
      hours: json['hours'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'hours': hours,
      };
}

class DietDataDto {
  final String meal;
  final String description;

  DietDataDto({required this.meal, required this.description});

  factory DietDataDto.fromJson(Map<String, dynamic> json) {
    return DietDataDto(
      meal: json['meal'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'meal': meal,
        'description': description,
      };
}

class WaterDataDto {
  final String day;
  final double liters;

  WaterDataDto({required this.day, required this.liters});

  factory WaterDataDto.fromJson(Map<String, dynamic> json) {
    return WaterDataDto(
      day: json['day'],
      liters: json['liters'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'liters': liters,
      };
}
