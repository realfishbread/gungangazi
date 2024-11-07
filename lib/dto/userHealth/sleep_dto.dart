
class SleepDto {
  final String date;
  final String sleepTime;
  final String wakeUpTime;

  SleepDto({
    required this.date,
    required this.sleepTime,
    required this.wakeUpTime,
  });

  factory SleepDto.fromJson(Map<String, dynamic> json) {
    return SleepDto(
      date: json['date'],
      sleepTime: json['sleepTime'],
      wakeUpTime: json['wakeUpTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sleepTime': sleepTime,
      'wakeUpTime': wakeUpTime,
    };
  }
}
