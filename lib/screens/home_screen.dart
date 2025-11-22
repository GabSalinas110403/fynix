import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';
import 'package:fynix/widgets/calendario_widget.dart';
import 'package:fynix/widgets/custom_scroll_screen.dart';
import 'package:fynix/widgets/notification_icon.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NECESARIO PARA PERSISTENCIA
import 'dart:convert'; // NECESARIO PARA JSON

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFF84B9BF);
  static const Color accentColor = Color(0xFFE1EDE9);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Clave de almacenamiento local para las tareas
  static const String _tasksKey = 'user_tasks';
  
  DateTime _selectedDay = DateTime.now(); 
  List<Task> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Cargar tareas al iniciar la pantalla
  }

  // -----------------------------------------------------------------
  // LÓGICA DE PERSISTENCIA
  // -----------------------------------------------------------------

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_tasksKey);

    if (tasksString != null) {
      final List<dynamic> taskListJson = jsonDecode(tasksString);
      setState(() {
        _allTasks = taskListJson.map((json) => Task.fromJson(json)).toList();
        _allTasks.sort((a, b) => a.date.compareTo(b.date));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskListString = _allTasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setString(_tasksKey, jsonEncode(taskListString));
  }

  // -----------------------------------------------------------------
  // LÓGICA DE GESTIÓN DE TAREAS
  // -----------------------------------------------------------------

  void _addOrUpdateTask(Task newTask, {int? index}) {
    setState(() {
      if (index == null) {
        // Asignación de ID si es nueva
        newTask.id = DateTime.now().toIso8601String(); 
        _allTasks.add(newTask);
      } else {
        // Actualizar tarea existente por índice
        _allTasks[index] = newTask;
      }
      _allTasks.sort((a, b) => a.date.compareTo(b.date));
    });
    _saveTasks(); // Guardar después de la modificación
  }

  void _deleteTask(Task taskToDelete) {
    setState(() {
      _allTasks.removeWhere((task) => task.id == taskToDelete.id);
    });
    _saveTasks(); // Guardar después de la modificación
  }

  void _onDateSelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    // Nota: El SnackBar (mensaje negro) ha sido eliminado por requerimiento.
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _allTasks.where((task) =>
        task.date.year == day.year &&
        task.date.month == day.month &&
        task.date.day == day.day
    ).toList();
  }
  
  void _addOrEditTaskDialog({Task? taskToEdit}) async {
    // Si el widget ya no está montado, salimos.
    if (!mounted) return; 
    
    final nameController = TextEditingController();
    DateTime dialogSelectedDate;
    String dialogSelectedCategory;

    if (taskToEdit != null) {
      nameController.text = taskToEdit.name;
      dialogSelectedDate = taskToEdit.date;
      dialogSelectedCategory = taskToEdit.category;
    } else {
      // Usar la fecha seleccionada en el calendario como valor por defecto
      dialogSelectedDate = _selectedDay; 
      dialogSelectedCategory = 'Personal';
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(taskToEdit == null ? "Agregar tarea" : "Editar tarea"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre de la tarea"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Fecha: "),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dialogSelectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          dialogSelectedDate = picked;
                        });
                      }
                    },
                    child: Text(DateFormat('dd/MM/yyyy').format(dialogSelectedDate)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Categoría: "),
                  DropdownButton<String>(
                    value: dialogSelectedCategory,
                    items: ['Personal', 'General', 'Otro']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          dialogSelectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              
              if (taskToEdit == null) {
                _addOrUpdateTask(
                  Task(
                    name: nameController.text,
                    date: dialogSelectedDate,
                    category: dialogSelectedCategory,
                  ),
                );
              } else {
                final updatedTask = Task(
                  id: taskToEdit.id,
                  name: nameController.text,
                  date: dialogSelectedDate,
                  category: dialogSelectedCategory,
                  completed: taskToEdit.completed,
                );
                final index = _allTasks.indexWhere((task) => task.id == taskToEdit.id);
                if (index != -1) {
                  _addOrUpdateTask(updatedTask, index: index);
                }
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // WIDGET PRINCIPAL BUILD
  // -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // 1. Contenido de Bienvenida (Se desplaza)
    final welcomeContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "USUARIO", 
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                )
              ),
              Text(
                "Hola de nuevo", 
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.white70
                )
              ),
            ],
          ),
        ),
      ],
    );

    // 2. Contenido Principal de la Pantalla (Calendario, Botón y Listas)
    final screenBody = Container(
      padding: const EdgeInsets.only(top: 16), 
      child: Column(
        // CORRECCIÓN: Ocupa solo el espacio de sus hijos para evitar errores de RenderFlex
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Contenedor del Calendario (Card) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: SizedBox( 
                height: 220, 
                width: double.infinity,
                child: CalendarWidget(
                  selectedDay: _selectedDay,
                  onDateSelected: _onDateSelected,
                  tasks: _allTasks,
                ), 
              ),
            ),
          ),
          
          // --- Fecha de Hoy y Botón de Agregar Tarea ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Muestra la fecha de HOY
                Text(
                  DateFormat('dd \'de\' MMMM yyyy', 'es_ES').format(DateTime.now()), 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                // Botón de Agregar Tarea (llama al diálogo)
                ElevatedButton.icon(
                  onPressed: () => _addOrEditTaskDialog(), 
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar tarea"),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16), 
          
          // --- Sección de Tareas del Día Seleccionado ---
          TaskSectionBase(
            title: 'Tareas del ${DateFormat('dd/MM').format(_selectedDay)}',
            tasks: _getTasksForDay(_selectedDay),
            emptyMessage: 'No hay tareas para el ${DateFormat('dd/MM').format(_selectedDay)}.',
            onEditTask: (task) => _addOrEditTaskDialog(taskToEdit: task),
            onDeleteTask: _deleteTask, 
            allTasks: _allTasks, 
          ),

          const SizedBox(height: 20),

          // --- SECCIÓN: Listado de TODAS las Tareas ---
          TaskSectionBase(
            title: "Todas las Tareas (${_allTasks.length})",
            tasks: List<Task>.from(_allTasks)..sort((a, b) => a.date.compareTo(b.date)),
            emptyMessage: 'No hay ninguna tarea registrada en el sistema.',
            onEditTask: (task) => _addOrEditTaskDialog(taskToEdit: task),
            onDeleteTask: _deleteTask,
            allTasks: _allTasks,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );

    // 3. Uso del widget genérico CustomScrollScreen
    return CustomScrollScreen(
      title: "Home",
      drawer: const CustomDrawer(),
      headerColor: HomeScreen.primaryColor,
      contentBackgroundColor: HomeScreen.accentColor, 
      topContent: welcomeContent, 
      actions: [
        // NOTIFICACIÓN: Usamos el widget reusable NotificationIcon
        NotificationIcon(allTasks: _allTasks),
        const SizedBox(width: 8),
      ],
      bodyContent: screenBody,
    );
  }
}

// ------------------- Task (DEFINICIÓN DE CLASE Y LÓGICA DE JSON) -------------------
class Task {
  String id; 
  String name;
  DateTime date;
  String category;
  bool completed;

  Task({
    String? id,
    required this.name,
    required this.date,
    required this.category,
    this.completed = false,
  }) : id = id ?? DateTime.now().toIso8601String();

  // Método para convertir la tarea a JSON (Map)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    // Guardar la fecha como ISO String para una fácil reconstrucción
    'date': date.toIso8601String(), 
    'category': category,
    'completed': completed,
  };

  // Factory constructor para crear una tarea desde JSON (Map)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      // Convertir el String de vuelta a DateTime
      date: DateTime.parse(json['date'] as String), 
      category: json['category'] as String,
      completed: json['completed'] as bool,
    );
  }

  String get status {
    if (completed) return "Completado";
    final now = DateTime.now();
    final taskDateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    
    if (taskDateOnly.isBefore(nowOnly)) return "Atrasado"; 
    return "Pendiente";
  }
}

// ------------------- TaskSectionBase (WIDGET ÚNICO DE VISUALIZACIÓN) -------------------

class TaskSectionBase extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  // showAddTaskButton fue eliminado de los parámetros porque su lógica 
  // ha sido movida a un botón fuera de esta sección en HomeScreen.
  final String emptyMessage;
  final Function(Task) onEditTask;
  final Function(Task) onDeleteTask;
  final List<Task> allTasks; // Necesario para la lógica de edición/eliminación

  const TaskSectionBase({
    super.key,
    required this.title,
    required this.tasks,
    required this.emptyMessage,
    required this.onEditTask, 
    required this.onDeleteTask,
    required this.allTasks,
  });

  Color _getStatusColor(Task task) {
    switch (task.status) {
      case "Completado":
        return Colors.green[100]!;
      case "Atrasado":
        return Colors.red[100]!;
      default:
        return Colors.yellow[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        elevation: 4, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            // La columna más externa de TaskSectionBase (dentro del Card)
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              tasks.isEmpty 
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Text(emptyMessage),
                    ),
                  )
                // Usamos Column y ListView.builder para la lista de tareas
                : Column( 
                    mainAxisSize: MainAxisSize.min, // Ajuste para evitar el error RenderFlex
                    children: [
                      ListView.builder(
                        // CRUCIAL: Resuelve el error de layout
                        shrinkWrap: true, 
                        // Evita que la lista intente hacer scroll dentro de un CustomScrollView
                        physics: const NeverScrollableScrollPhysics(), 
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            color: _getStatusColor(task),
                            child: ListTile(
                              leading: Checkbox(
                                shape: const CircleBorder(),
                                value: task.completed,
                                onChanged: (value) {
                                  final updatedTask = Task(
                                    id: task.id,
                                    name: task.name,
                                    date: task.date,
                                    category: task.category,
                                    completed: value ?? false,
                                  );
                                  onEditTask(updatedTask);
                                },
                              ),
                              title: Text(task.name),
                              subtitle: Text(
                                  "Fecha: ${task.date.day}/${task.date.month}/${task.date.year} - ${task.category} - ${task.status}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => onEditTask(task),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => onDeleteTask(task),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}