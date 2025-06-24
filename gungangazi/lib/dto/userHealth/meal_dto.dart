class MealDTO {
  final String id;
  final String date;
  final String meal;
  final String username;
  final int calories;
  final String meal_type; // "식사" 또는 "간식" 구분

  MealDTO({
    required this.id,
    required this.date,
    required this.meal,
    required this.username,
    required this.calories,
    required this.meal_type,
  });

  factory MealDTO.fromJson(Map<String, dynamic> json) {
    return MealDTO(
      id: json['id'],
      date: json['date'],
      meal: json['meal'],
      username: json['username'],
      calories: json['calories'],
      meal_type: json['meal_type'], // JSON에서 mealType 가져오기
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'meal': meal,
      'username': username,
      'calories': calories,
      'meal_type': meal_type, // JSON에 mealType 포함
    };
  }
}
