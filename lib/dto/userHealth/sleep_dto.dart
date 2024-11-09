
class SleepDto {
  final String date;
  final String sleepTime;
  final String wakeUpTime;
  final String username;

  SleepDto({
    required this.date,
    required this.sleepTime,
    required this.wakeUpTime,
    required this.username
  });

  factory SleepDto.fromJson(Map<String, dynamic> json) {
    return SleepDto(
      date: json['date'],
      sleepTime: json['sleepTime'],
      wakeUpTime: json['wakeUpTime'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sleepTime': sleepTime,
      'wakeUpTime': wakeUpTime,
      'username': username
    };
  }
}
