class MealDTO {
  final String date;
  final String mealContent;

  MealDTO({required this.date, required this.mealContent});

  // JSON -> 객체 변환
  factory MealDTO.fromJson(Map<String, dynamic> json) {
    return MealDTO(
      date: json['date'] as String,
      mealContent: json['mealContent'] as String,
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mealContent': mealContent,
    };
  }
}
