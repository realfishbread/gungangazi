class BloodPressureDTO {
  final String systolic;
  final String diastolic;
  final String heart_rate;
  final String date;
  final String username;
  final String? id;

  BloodPressureDTO({
    required this.systolic,
    required this.diastolic,
    required this.heart_rate,
    required this.date,
    required this.username,
    this.id,
  });

  // 서버로 보낼 때 사용되는 Map 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'heart_rate': heart_rate,
      'date': date,
      'username': username,
      'id': id,
    };
  }

  // 서버에서 가져올 때 사용되는 생성자
  factory BloodPressureDTO.fromJson(Map<String, dynamic> json) {
    return BloodPressureDTO(
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      heart_rate: json['heart_rate'],
      date: json['date'],
      username: json['username'],
      id: json['id'] ?? ' ', // JSON에서 id가 없으면 기본값으로 빈 문자열 사용
    );
  }
}