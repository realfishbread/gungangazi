class HealthRecordDto {
  final int stepCount;
  final double calories;
  final int sleepMinutes;

  HealthRecordDto({
    required this.stepCount,
    required this.calories,
    required this.sleepMinutes,
  });

  /// JSON 데이터를 모델 객체로 변환 (DTO 역할)
  factory HealthRecordDto.fromJson(Map<String, dynamic> json) {
    return HealthRecordDto(
      stepCount: json['stepCount'] ?? 0,
      calories: json['calories'] ?? 0.0,
      sleepMinutes: json['sleepMinutes'] ?? 0,
    );
  }

  /// 모델 객체를 JSON으로 변환 (서버로 전송할 때)
  Map<String, dynamic> toJson() {
    return {
      'stepCount': stepCount,
      'calories': calories,
      'sleepMinutes': sleepMinutes,
    };
  }
}
