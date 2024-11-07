class SupplementDto {
  final DateTime date;
  final bool supplementTaken;
  final bool menstruationRecorded;

  SupplementDto({
    required this.date,
    required this.supplementTaken,
    required this.menstruationRecorded,
  });

  // JSON 데이터로부터 객체를 생성합니다.
  factory SupplementDto.fromJson(Map<String, dynamic> json) {
    return SupplementDto(
      date: DateTime.parse(json['date']),
      supplementTaken: json['supplementTaken'],
      menstruationRecorded: json['menstruationRecorded'],
    );
  }

  // 객체를 JSON으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'supplementTaken': supplementTaken,
      'menstruationRecorded': menstruationRecorded,
    };
  }
}
