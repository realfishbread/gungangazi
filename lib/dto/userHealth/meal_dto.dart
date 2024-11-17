class MealDTO {
  final String? id;
  final String date;
  final String meal;
  final String username;
  final int calories;
  final String mealType; // "식사" 또는 "간식" 구분

  MealDTO({
    this.id,
    required this.date,
    required this.meal,
    required this.username,
    required this.calories,
    required this.mealType,
  });

  factory MealDTO.fromJson(Map<String, dynamic> json) {
    return MealDTO(
      id: json['id'],
      date: json['date'],
      meal: json['meal'],
      username: json['username'],
      calories: json['calories'],
      mealType: json['mealType'], // JSON에서 mealType 가져오기
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'meal': meal,
      'username': username,
      'calories': calories,
      'mealType': mealType, // JSON에 mealType 포함
    };
  }
}
