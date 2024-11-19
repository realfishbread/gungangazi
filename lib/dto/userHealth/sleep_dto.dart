
class SleepDto {
  final String date;
  final String sleep_time;
  final String wake_up_time;
  final String username;

  SleepDto({
    required this.date,
    required this.sleep_time,
    required this.wake_up_time,
    required this.username
  });

  factory SleepDto.fromJson(Map<String, dynamic> json) {
    return SleepDto(
      date: json['date'],
      sleep_time: json['sleep_time'],
      wake_up_time: json['wake_up_time'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sleep_time': sleep_time,
      'wake_up_time': wake_up_time,
      'username': username
    };
  }
}
