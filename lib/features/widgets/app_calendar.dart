import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final CalendarFormat calendarFormat;
  final void Function(CalendarFormat format)? onFormatChanged;
  final bool Function(DateTime day)? enabledDayPredicate;

  const AppCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    this.firstDay,
    this.lastDay,
    this.calendarFormat = CalendarFormat.month,
    this.onFormatChanged,
    this.enabledDayPredicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    final baseFirstDay = firstDay ?? DateTime.now().subtract(const Duration(days: 365));
    final baseLastDay = lastDay ?? DateTime.now().add(const Duration(days: 365));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: baseFirstDay,
        lastDay: baseLastDay,
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        enabledDayPredicate: enabledDayPredicate,
        
        // Estilo do cabeçalho
        headerStyle: HeaderStyle(
          formatButtonVisible: onFormatChanged != null,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
        ),

        // Estilos de calendário customizados para combinar com o tom de rosa / rose gold
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: secondaryColor.withValues(alpha: 0.24),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          outsideDaysVisible: false,
          disabledTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
        ),

        // Dias da semana
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: primaryColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
