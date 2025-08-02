// 캘린더 전용 위젯

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SupplementCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final Map<DateTime, bool> supplementTaken;
  final Set<DateTime> menstruationDays;
  final Function(DateTime) onDaySelected;

  const SupplementCalendar({
    super.key,
    required this.selectedDay,
    required this.supplementTaken,
    required this.menstruationDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: selectedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) => onDaySelected(selectedDay),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          final dateOnly = DateTime(date.year, date.month, date.day);
          if (menstruationDays.contains(dateOnly) && (supplementTaken[dateOnly] == true)) {
            return _buildCircle(date.day, Colors.purple);
          } else if (menstruationDays.contains(dateOnly)) {
            return _buildCircle(date.day, Colors.red);
          } else if (supplementTaken[dateOnly] == true) {
            return _buildCircle(date.day, Colors.blue);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCircle(int day, Color color) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle),
      child: Center(child: Text('$day')),
    );
  }
}
