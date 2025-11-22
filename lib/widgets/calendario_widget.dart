import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fynix/screens/home_screen.dart'; 

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDateSelected; 
  final List<Task> tasks;

  const CalendarWidget({
    super.key,
    required this.selectedDay,
    required this.onDateSelected,
    required this.tasks, 
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      _focusedDay = widget.selectedDay;
    }
  }

  // Función para obtener los días de la semana actual
  List<DateTime> _getWeekDays(DateTime date) {
    // Obtener el lunes de esta semana
    int weekday = date.weekday;
    DateTime monday = date.subtract(Duration(days: weekday - 1));

    // Generar la semana completa a partir del lunes
    List<DateTime> weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
    
    return weekDays;
  }

  // Función para verificar si un día tiene tareas
  bool _hasTasksForDay(DateTime day) {
    return widget.tasks.any((task) =>
        task.date.year == day.year &&
        task.date.month == day.month &&
        task.date.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekDays = _getWeekDays(_focusedDay);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Encabezado del Calendario (Mes y Año)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                    widget.onDateSelected(_focusedDay); 
                  });
                },
              ),
              Text(
                DateFormat.yMMMM('es_ES').format(_focusedDay), // Formato: Noviembre 2025
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _focusedDay = _focusedDay.add(const Duration(days: 7));
                    widget.onDateSelected(_focusedDay);
                  });
                },
              ),
            ],
          ),
        ),
        
        // Días de la semana (Dom, Lun, Mar...) y Números del día
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currentWeekDays.map((day) {
              final bool isSelected = day.year == widget.selectedDay.year &&
                                      day.month == widget.selectedDay.month &&
                                      day.day == widget.selectedDay.day;
              final bool hasTasks = _hasTasksForDay(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onDateSelected(day),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? HomeScreen.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E('es_ES').format(day).substring(0, 3), 
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasTasks) 
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : HomeScreen.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (!hasTasks) const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}