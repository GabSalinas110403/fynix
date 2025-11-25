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
  
  // Filtros avanzados
  String? filtroCampoSeleccionado; // 'nombre', 'id', 'descripcion'
  String? filtroMesSeleccionado;

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
    String query = searchController.text.toLowerCase().trim();
    setState(() {
      proveedoresFiltrados = proveedores.where((proveedor) {
        // Filtro de búsqueda por texto según el campo seleccionado
        bool matchesSearch = query.isEmpty;
        
        if (!matchesSearch && query.isNotEmpty) {
          if (filtroCampoSeleccionado == null) {
            // Si no hay campo seleccionado, buscar en todos
            matchesSearch = proveedor.id.toLowerCase().contains(query) ||
                proveedor.nombre.toLowerCase().contains(query) ||
                proveedor.descripcion.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'nombre') {
            matchesSearch = proveedor.nombre.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'id') {
            matchesSearch = proveedor.id.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'descripcion') {
            matchesSearch = proveedor.descripcion.toLowerCase().contains(query);
          }
        } else {
          matchesSearch = true;
        }

        // Filtro por mes
        bool matchesMes = true;
        if (filtroMesSeleccionado != null) {
          matchesMes = proveedor.fecha.toLowerCase().contains(filtroMesSeleccionado!.toLowerCase());
        }

        return matchesSearch && matchesMes;
      }).toList();
    });
  }

  void _mostrarFiltros() {
    final meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? tempFiltroCampo = filtroCampoSeleccionado;
        String? tempFiltroMes = filtroMesSeleccionado;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempFiltroCampo = null;
                              tempFiltroMes = null;
                            });
                          },
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Buscar por Campo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Selecciona en qué campo buscar (si no seleccionas, buscará en todos)',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        FilterChip(
                          label: const Text('Nombre'),
                          selected: tempFiltroCampo == 'nombre',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'nombre' : null;
                            });
                          },
                          selectedColor: ProveedoresScreen.primaryColor.withOpacity(0.3),
                        ),
                        FilterChip(
                          label: const Text('ID'),
                          selected: tempFiltroCampo == 'id',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'id' : null;
                            });
                          },
                          selectedColor: ProveedoresScreen.primaryColor.withOpacity(0.3),
                        ),
                        FilterChip(
                          label: const Text('Descripción'),
                          selected: tempFiltroCampo == 'descripcion',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'descripcion' : null;
                            });
                          },
                          selectedColor: ProveedoresScreen.primaryColor.withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filtrar por Mes de Registro',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: meses.map((mes) {
                        return FilterChip(
                          label: Text(mes.toUpperCase()),
                          selected: tempFiltroMes == mes,
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroMes = selected ? mes : null;
                            });
                          },
                          selectedColor: Colors.blue[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filtroCampoSeleccionado = tempFiltroCampo;
                            filtroMesSeleccionado = tempFiltroMes;
                          });
                          _filterProveedores();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ProveedoresScreen.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Aplicar Filtros',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  String _getNombreCampo(String campo) {
    switch (campo) {
      case 'nombre':
        return 'Nombre';
      case 'id':
        return 'ID';
      case 'descripcion':
        return 'Descripción';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220.0,
            backgroundColor: ProveedoresScreen.primaryColor,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              NotificationIcon(allTasks: allTasks),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(),
              background: Container(
                color: ProveedoresScreen.primaryColor,
                padding: const EdgeInsets.only(top: 80, bottom: 20, left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Proveedores',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Gestión de Proveedores',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: ProveedoresScreen.accentColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildProveedoresList(),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
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
                  decoration: InputDecoration(
                    hintText: filtroCampoSeleccionado == null 
                      ? "Buscar . . ." 
                      : "Buscar en ${_getNombreCampo(filtroCampoSeleccionado!)}...",
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: ProveedoresScreen.primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: filtroCampoSeleccionado != null || filtroMesSeleccionado != null
                  ? ProveedoresScreen.primaryColor
                  : Colors.white.withOpacity(0.9),
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
                icon: Icon(
                  Icons.filter_list, 
                  color: filtroCampoSeleccionado != null || filtroMesSeleccionado != null
                    ? Colors.white
                    : ProveedoresScreen.primaryColor, 
                  size: 28
                ),
                onPressed: _mostrarFiltros,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedoresList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
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