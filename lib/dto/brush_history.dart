// dto/brush_history_dto.dart
class BrushHistoryDTO {
  final String date;
  final int duration;
  final bool flossed;

  BrushHistoryDTO({required this.date, required this.duration, required this.flossed});

  factory BrushHistoryDTO.fromJson(Map<String, dynamic> json) {
    return BrushHistoryDTO(
      date: json['date'],
      duration: json['duration'],
      flossed: json['flossed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'duration': duration,
      'flossed': flossed,
    };
  }
}
