import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';
import 'package:fynix/widgets/calendario_widget.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Color(0xFF84B9BF),
      ),

      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,   
            end: Alignment.bottomCenter, 
            colors: [
              Color(0xFF84B9BF), 
              Color(0xFFE1EDE9)      
            ],
            stops: [0.3, 0.3], 
          ),
        ),
        child: SingleChildScrollView(
          
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: const [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Hola de nuevo",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "USUARIO",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // Ajusté el radio para que se vea como en el prototipo
                    ),
                    // Aquí reemplazas el SizedBox vacío:
                    child: const SizedBox( 
                        height: 220, // Altura ajustada para contener el contenido del CalendarWidget
                        width: double.infinity,
                        child: CalendarWidget(), // ¡Aquí está el calendario funcional!
                    ),
                ),
            ),
            const SizedBox(height: 16),
              
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text("Actividades Recientes",
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          

              
            ),
            const SizedBox(height: 0),
            SizedBox(
              height: 200, // Altura del carrusel de tarjetas 
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10 ),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    cardGrafica(title: "Actividad"),
                    cardGrafica(title: "Finanzas"),
                    cardGrafica(title: "Proveedores"),
                    cardGrafica(title: "Reporte Mensual"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),


            const TaskSection(),
              
            ],
          ),
        ),
      ),
    );
  }
}

Widget cardGrafica({required String title}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12), // Espaciado entre cards
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 200, // Ancho de cada tarjeta
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Text(
              "Próxima gráfica...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}


class Task {
  String name;
  DateTime date;
  String category;
  bool completed;

  Task({
    required this.name,
    required this.date,
    required this.category,
    this.completed = false,
  });

  String get status {
    if (completed) return "Completado";
    if (date.isBefore(DateTime.now())) return "Atrasado";
    return "Pendiente";
  }
}

class TaskSection extends StatefulWidget {
  const TaskSection({super.key});

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  final List<Task> tasks = [];
  final TextEditingController nameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'Personal';

  void _addOrEditTask({int? index}) async {
    if (index != null) {
      nameController.text = tasks[index].name;
      selectedDate = tasks[index].date;
      selectedCategory = tasks[index].category;
    } else {
      nameController.clear();
      selectedDate = DateTime.now();
      selectedCategory = 'Personal';
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? "Agregar tarea" : "Editar tarea"),
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
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Categoría: "),
                  DropdownButton<String>(
                    value: selectedCategory,
                    items: ['Personal', 'General', 'Otro']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          selectedCategory = value;
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
                setState(() {
                  if (index == null) {
                    tasks.add(Task(
                        name: nameController.text,
                        date: selectedDate,
                        category: selectedCategory));
                  } else {
                    tasks[index].name = nameController.text;
                    tasks[index].date = selectedDate;
                    tasks[index].category = selectedCategory;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar")),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

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
        elevation: 4, //efecto de sombra
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tareas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _addOrEditTask(),
                icon: const Icon(Icons.add),
                label: const Text("Agregar tarea"),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: tasks.isEmpty
                    ? const Center(child: Text("No hay tareas aún."))
                    : ListView.builder(
                        shrinkWrap: true,
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
                                  setState(() {
                                    task.completed = value ?? false;
                                  });
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
                                    onPressed: () => _addOrEditTask(index: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteTask(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
