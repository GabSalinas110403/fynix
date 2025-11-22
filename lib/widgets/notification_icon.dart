import 'package:flutter/material.dart';
import 'package:fynix/screens/home_screen.dart'; // Importar Task y HomeScreen

class NotificationIcon extends StatelessWidget {
  final List<Task> allTasks;

  const NotificationIcon({super.key, required this.allTasks});

  // Obtiene las tareas pendientes (no completadas) para el día de hoy
  List<Task> _getPendingTasksForToday() {
    final today = DateTime.now();
    return allTasks.where((task) {
      final taskDate = task.date;
      return !task.completed && 
             taskDate.year == today.year &&
             taskDate.month == today.month &&
             taskDate.day == today.day;
    }).toList();
  }
  
  // Muestra el diálogo de notificaciones al hacer clic en el icono
  void _showNotificationDialog(BuildContext context) {
    final pendingTasks = _getPendingTasksForToday();
    String title;
    Widget content;

    if (pendingTasks.isEmpty) {
      title = "Notificaciones (Hoy)";
      content = const Text("¡No tienes tareas pendientes para el día de hoy!");
    } else {
      title = "Tienes ${pendingTasks.length} Tarea(s) Pendiente(s) Hoy:";
      content = SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: pendingTasks.length,
          itemBuilder: (context, index) {
            final task = pendingTasks[index];
            return ListTile(
              title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(task.category),
              trailing: const Icon(Icons.warning, color: Colors.red),
            );
          },
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingTasksToday = _getPendingTasksForToday().isNotEmpty;
    
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_none, 
            color: hasPendingTasksToday ? Colors.redAccent : Colors.white, 
            size: 30
          ),
          onPressed: () => _showNotificationDialog(context), // Llama al diálogo
        ),
        if (hasPendingTasksToday)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                _getPendingTasksForToday().length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}