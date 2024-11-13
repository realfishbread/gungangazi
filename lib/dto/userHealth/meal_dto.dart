class MealDTO {
  final String date;
  final String meal;
  final String username;  // 여기에 username을 추가

  MealDTO({
    required this.date,
    required this.meal,
    required this.username,  // username을 생성자에 추가
  });

  // JSON -> 객체 변환
  factory MealDTO.fromJson(Map<String, dynamic> json) {
    return MealDTO(
      date: json['date'] as String,
      meal: json['meal'] as String,
      username: json['username'] as String,  // username 추가
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'meal': meal,
      'username': username,  // username 추가
    };
  }
}
