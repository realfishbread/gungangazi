import 'package:flutter/material.dart';

class CharacterStatus extends StatelessWidget {
  final double sleepProgress; // 수면 진행률 (예: 0.75는 75%)
  final double mealProgress;  // 식단 진행률
  final double waterProgress; // 수분 진행률

  const CharacterStatus({
    Key? key,
    required this.sleepProgress,
    required this.mealProgress,
    required this.waterProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBar("수면", sleepProgress, Colors.blue),
        const SizedBox(height: 8),
        _buildStatusBar("식단", mealProgress, Colors.green),
        const SizedBox(height: 8),
        _buildStatusBar("수분", waterProgress, Colors.blueAccent),
      ],
    );
  }

  Widget _buildStatusBar(String label, double progress, Color color) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: progress, // 진행률 (0.0 ~ 1.0)
            color: color,
            backgroundColor: Colors.grey[200],
          ),
        ),
        const SizedBox(width: 8),
        Text("${(progress * 100).toInt()}%"),
      ],
    );
  }
}
