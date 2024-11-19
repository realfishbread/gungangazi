class BrushHistoryDTO {
  final String date;
  final int duration;
  final bool flossed;
  final String? username;
 

  BrushHistoryDTO({
    required this.date,
    required this.duration,
    required this.flossed,
    required this.username
  });

  factory BrushHistoryDTO.fromJson(Map<String, dynamic> json) {
    return BrushHistoryDTO(
      date: json['date'],
      duration: json['duration'],
      flossed: json['flossed'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'duration': duration,
      'flossed': flossed,
      'username': username
    };
  }
}

