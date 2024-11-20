class SupplementDto {
  final DateTime date;
  final bool supplement_taken;
  final bool menstruation_recorded;
  final String username;

  SupplementDto({
    required this.date,
    required this.supplement_taken,
    required this.menstruation_recorded,
    required this.username,
  });

  // JSON 데이터로부터 객체를 생성합니다.
  factory SupplementDto.fromJson(Map<String, dynamic> json) {
    return SupplementDto(
      date: DateTime.parse(json['date']),
      supplement_taken: json['supplement_taken'],
      menstruation_recorded: json['menstruation_recorded'],
      username: json['username'],
    );
  }

  // 객체를 JSON으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'supplement_taken': supplement_taken,
      'menstruation_recorded': menstruation_recorded,
      'username': username,
    };
  }
}
