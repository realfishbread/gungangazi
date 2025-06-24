class WaterDataDto {
  final String date;
  final int amount;

  WaterDataDto({required this.date, required this.amount});

  // JSON 데이터를 `WaterDataDto` 객체로 변환하는 팩토리 메서드
  factory WaterDataDto.fromJson(Map<String, dynamic> json) {
    return WaterDataDto(
      date: json['date'] as String,
      amount: json['amount'] as int,
    );
  }

  // `WaterDataDto` 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
    };
  }
}
