import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fynix/widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart';
import 'home_screen.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  static const Color primaryColor = Color(0xFF84B9BF);
  static const Color accentColor = Color(0xFFE1EDE9);
  static const Color textColor = Color(0xFF06373E);

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  List<Task> allTasks = [];
  List<Empleado> empleados = [];
  List<Empleado> empleadosFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _initializeEmpleados();
    searchController.addListener(_filterEmpleados);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('user_tasks');

    if (tasksString != null) {
      final List<dynamic> taskListJson = jsonDecode(tasksString);
      setState(() {
        allTasks = taskListJson.map((json) => Task.fromJson(json)).toList();
      });
    }
  }

  void _initializeEmpleados() {
    empleados = [
      Empleado(
        id: 'EMP-001',
        nombre: 'Juan Pérez García',
        puesto: 'Gerente General',
        sueldo: 25000.00,
        vacacionesPendientes: 5,
        activo: true,
      ),
      Empleado(
        id: 'EMP-002',
        nombre: 'María López Hernández',
        puesto: 'Contador',
        sueldo: 18000.00,
        vacacionesPendientes: 0,
        activo: true,
      ),
      Empleado(
        id: 'EMP-003',
        nombre: 'Carlos Ramírez Torres',
        puesto: 'Desarrollador Senior',
        sueldo: 22000.00,
        vacacionesPendientes: 3,
        activo: true,
      ),
      Empleado(
        id: 'EMP-004',
        nombre: 'Ana Martínez Sánchez',
        puesto: 'Recursos Humanos',
        sueldo: 16000.00,
        vacacionesPendientes: 2,
        activo: true,
      ),
    ];
    empleadosFiltrados = List.from(empleados);
  }

  void _filterEmpleados() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        empleadosFiltrados = List.from(empleados);
      } else {
        empleadosFiltrados = empleados.where((empleado) {
          return empleado.nombre.toLowerCase().contains(query) ||
              empleado.id.toLowerCase().contains(query) ||
              empleado.puesto.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  int get empleadosActivos => empleados.where((e) => e.activo).length;
  int get vacacionesPendientes => empleados.fold(0, (sum, e) => sum + e.vacacionesPendientes);
  int get proximosEventos => 1; // Puede ser calculado según eventos reales

  void _agregarEmpleado() {
    final nombreController = TextEditingController();
    final puestoController = TextEditingController();
    final sueldoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar Empleado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: puestoController,
                decoration: const InputDecoration(
                  labelText: 'Puesto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: sueldoController,
                decoration: const InputDecoration(
                  labelText: 'Sueldo (MXN)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.trim().isEmpty ||
                  puestoController.text.trim().isEmpty) return;

              double sueldo = double.tryParse(sueldoController.text) ?? 0.0;

              setState(() {
                int nextId = empleados.length + 1;
                empleados.add(
                  Empleado(
                    id: 'EMP-${nextId.toString().padLeft(3, '0')}',
                    nombre: nombreController.text.trim(),
                    puesto: puestoController.text.trim(),
                    sueldo: sueldo,
                    vacacionesPendientes: 0,
                    activo: true,
                  ),
                );
                _filterEmpleados();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Empleado agregado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PersonalScreen.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarEmpleado(Empleado empleado) {
    final nombreController = TextEditingController(text: empleado.nombre);
    final puestoController = TextEditingController(text: empleado.puesto);
    final sueldoController = TextEditingController(text: empleado.sueldo.toString());
    final vacacionesController = TextEditingController(text: empleado.vacacionesPendientes.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Empleado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: puestoController,
                decoration: const InputDecoration(
                  labelText: 'Puesto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: sueldoController,
                decoration: const InputDecoration(
                  labelText: 'Sueldo (MXN)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: vacacionesController,
                decoration: const InputDecoration(
                  labelText: 'Vacaciones Pendientes (días)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.trim().isEmpty ||
                  puestoController.text.trim().isEmpty) return;

              double sueldo = double.tryParse(sueldoController.text) ?? empleado.sueldo;
              int vacaciones = int.tryParse(vacacionesController.text) ?? empleado.vacacionesPendientes;

              setState(() {
                int index = empleados.indexWhere((e) => e.id == empleado.id);
                if (index != -1) {
                  empleados[index] = Empleado(
                    id: empleado.id,
                    nombre: nombreController.text.trim(),
                    puesto: puestoController.text.trim(),
                    sueldo: sueldo,
                    vacacionesPendientes: vacaciones,
                    activo: empleado.activo,
                  );
                  _filterEmpleados();
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Empleado actualizado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PersonalScreen.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _toggleEstadoEmpleado(Empleado empleado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(empleado.activo ? 'Desactivar Empleado' : 'Activar Empleado'),
        content: Text(
          empleado.activo
              ? '¿Deseas marcar a ${empleado.nombre} como inactivo?'
              : '¿Deseas reactivar a ${empleado.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                int index = empleados.indexWhere((e) => e.id == empleado.id);
                if (index != -1) {
                  empleados[index] = Empleado(
                    id: empleado.id,
                    nombre: empleado.nombre,
                    puesto: empleado.puesto,
                    sueldo: empleado.sueldo,
                    vacacionesPendientes: empleado.vacacionesPendientes,
                    activo: !empleado.activo,
                  );
                  _filterEmpleados();
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(empleado.activo
                      ? 'Empleado desactivado'
                      : 'Empleado reactivado'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: empleado.activo ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(empleado.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarEmpleado,
        backgroundColor: PersonalScreen.primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PersonalScreen.primaryColor,
              PersonalScreen.accentColor,
            ],
            stops: [0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildEmpleadosList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Spacer(),
                NotificationIcon(allTasks: allTasks),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Text(
            'Personal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Gestión de Recursos Humanos',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatContainer(
                    'Empleados activos:',
                    empleadosActivos.toString(),
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatContainer(
                    'Vacaciones pendientes:',
                    vacacionesPendientes.toString(),
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatContainer(
                    'Próximos eventos:',
                    proximosEventos.toString(),
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatContainer(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PersonalScreen.primaryColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PersonalScreen.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: PersonalScreen.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        transform: Matrix4.translationValues(0.0, 6.0, 0.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Buscar . . .",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: PersonalScreen.primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list, color: PersonalScreen.primaryColor, size: 28),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtros próximamente')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpleadosList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: empleadosFiltrados.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron empleados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: empleadosFiltrados
                  .map((empleado) => _buildEmployeeCard(empleado))
                  .toList(),
            ),
    );
  }

  Widget _buildEmployeeCard(Empleado empleado) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: empleado.activo ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PersonalScreen.primaryColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            empleado.id,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          if (!empleado.activo) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'INACTIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        empleado.nombre,
                        style: const TextStyle(
                          color: PersonalScreen.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Puesto: ${empleado.puesto}',
                        style: const TextStyle(
                          color: PersonalScreen.textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sueldo: \$${empleado.sueldo.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          color: PersonalScreen.textColor,
                          fontSize: 14,
                        ),
                      ),
                      if (empleado.vacacionesPendientes > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Vacaciones pendientes: ${empleado.vacacionesPendientes} días',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.groups,
                  size: 50,
                  color: PersonalScreen.primaryColor.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                  onPressed: () => _editarEmpleado(empleado),
                ),
                IconButton(
                  icon: Icon(
                    empleado.activo ? Icons.person_off : Icons.person,
                    color: empleado.activo ? Colors.orange : Colors.green,
                    size: 22,
                  ),
                  onPressed: () => _toggleEstadoEmpleado(empleado),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Empleado {
  final String id;
  final String nombre;
  final String puesto;
  final double sueldo;
  final int vacacionesPendientes;
  final bool activo;

  Empleado({
    required this.id,
    required this.nombre,
    required this.puesto,
    required this.sueldo,
    required this.vacacionesPendientes,
    required this.activo,
  });
}