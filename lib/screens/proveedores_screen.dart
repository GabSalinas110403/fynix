import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fynix/widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart';
import 'home_screen.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  static const Color primaryColor = Color(0xFF84B9BF);
  static const Color accentColor = Color(0xFFE1EDE9);
  static const Color textColor = Color(0xFF06373E);

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  List<Task> allTasks = [];
  List<Proveedor> proveedores = [];
  List<Proveedor> proveedoresFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _initializeProveedores();
    searchController.addListener(_filterProveedores);
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

  void _initializeProveedores() {
    proveedores = [
      Proveedor(
        id: 'PRO-001',
        nombre: 'Suministros Tecnológicos del Norte S.A. de C.V.',
        fecha: '15 sep 2025',
        descripcion: 'Suministros de Papel de oficina, tóner para impresoras, productos de limpieza.',
      ),
      Proveedor(
        id: 'PRO-002',
        nombre: 'Mobiliario Fénix Express S. de R.L.',
        fecha: '10 oct 2025',
        descripcion: 'Escritorios ergonómicos, sillas de oficina y archivadores metálicos.',
      ),
      Proveedor(
        id: 'PRO-003',
        nombre: 'Servicios de Internet Ultra',
        fecha: '22 nov 2025',
        descripcion: 'Servicio de Internet de alta velocidad y telefonía IP para oficinas.',
      ),
    ];
    proveedoresFiltrados = List.from(proveedores);
  }

  void _filterProveedores() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        proveedoresFiltrados = List.from(proveedores);
      } else {
        proveedoresFiltrados = proveedores.where((proveedor) {
          return proveedor.nombre.toLowerCase().contains(query) ||
              proveedor.id.toLowerCase().contains(query) ||
              proveedor.descripcion.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _agregarProveedor() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proveedor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              if (nombreController.text.trim().isEmpty) return;

              setState(() {
                int nextId = proveedores.length + 1;
                proveedores.add(
                  Proveedor(
                    id: 'PRO-${nextId.toString().padLeft(3, '0')}',
                    nombre: nombreController.text.trim(),
                    fecha: _formatDate(DateTime.now()),
                    descripcion: descripcionController.text.trim(),
                  ),
                );
                _filterProveedores();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proveedor agregado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ProveedoresScreen.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarProveedor(Proveedor proveedor) {
    final nombreController = TextEditingController(text: proveedor.nombre);
    final descripcionController = TextEditingController(text: proveedor.descripcion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proveedor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              if (nombreController.text.trim().isEmpty) return;

              setState(() {
                int index = proveedores.indexWhere((p) => p.id == proveedor.id);
                if (index != -1) {
                  proveedores[index] = Proveedor(
                    id: proveedor.id,
                    nombre: nombreController.text.trim(),
                    fecha: proveedor.fecha,
                    descripcion: descripcionController.text.trim(),
                  );
                  _filterProveedores();
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proveedor actualizado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ProveedoresScreen.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _eliminarProveedor(Proveedor proveedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Estás seguro de eliminar a ${proveedor.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                proveedores.removeWhere((p) => p.id == proveedor.id);
                _filterProveedores();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proveedor eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ProveedoresScreen.primaryColor,
              ProveedoresScreen.accentColor,
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
                      _buildProveedoresList(),
                      const SizedBox(height: 30),
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
      padding: const EdgeInsets.only(bottom: 50),
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
            'Proveedores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Gestión de Proveedores',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _agregarProveedor,
            icon: const Icon(Icons.add, color: ProveedoresScreen.primaryColor),
            label: const Text(
              '+ Proveedores',
              style: TextStyle(
                color: ProveedoresScreen.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 5,
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
                    icon: Icon(Icons.search, color: ProveedoresScreen.primaryColor),
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
                icon: const Icon(Icons.filter_list, color: ProveedoresScreen.primaryColor, size: 28),
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

  Widget _buildProveedoresList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: proveedoresFiltrados.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron proveedores',
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
              children: proveedoresFiltrados
                  .map((proveedor) => _buildProveedorCard(proveedor))
                  .toList(),
            ),
    );
  }

  Widget _buildProveedorCard(Proveedor proveedor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ProveedoresScreen.primaryColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  proveedor.fecha,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () => _editarProveedor(proveedor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _eliminarProveedor(proveedor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              proveedor.nombre,
              style: const TextStyle(
                color: ProveedoresScreen.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ID: ${proveedor.id}',
              style: const TextStyle(color: ProveedoresScreen.textColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              proveedor.descripcion,
              style: TextStyle(
                color: ProveedoresScreen.textColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Proveedor {
  final String id;
  final String nombre;
  final String fecha;
  final String descripcion;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.descripcion,
  });
}