class BrushHistoryDTO {
  final String id;
  final String date;
  final int duration;
  final bool flossed;
  final String? username;
 

  BrushHistoryDTO({
    required this.id,
    required this.date,
    required this.duration,
    required this.flossed,
    required this.username
  });

  factory BrushHistoryDTO.fromJson(Map<String, dynamic> json) {
    return BrushHistoryDTO(
      id: json['id'],
      date: json['date'],
      duration: json['duration'],
      flossed: json['flossed'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
      'flossed': flossed,
      'username': username
    };
  }
}

