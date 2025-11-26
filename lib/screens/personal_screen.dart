import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fynix/widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart';
import 'home_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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

  // Filtros avanzados
  String? filtroCampoSeleccionado; // 'nombre', 'id', 'puesto'
  bool? filtroActivoSeleccionado; // true (Activos), false (Inactivos), null (Todos)

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
      Empleado(
        id: 'EMP-005',
        nombre: 'Pedro Gómez Ruiz',
        puesto: 'Ventas',
        sueldo: 15000.00,
        vacacionesPendientes: 1,
        activo: false,
      ),
    ];
    empleadosFiltrados = List.from(empleados);
  }

  void _filterEmpleados() {
    String query = searchController.text.toLowerCase().trim();
    setState(() {
      empleadosFiltrados = empleados.where((empleado) {
        // 1. Filtro de búsqueda por texto y campo seleccionado
        bool matchesSearch = query.isEmpty;

        if (!matchesSearch && query.isNotEmpty) {
          if (filtroCampoSeleccionado == 'nombre') {
            matchesSearch = empleado.nombre.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'id') {
            matchesSearch = empleado.id.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'puesto') {
            matchesSearch = empleado.puesto.toLowerCase().contains(query);
          } else {
            // Si no hay campo seleccionado, buscar en todos
            matchesSearch = empleado.nombre.toLowerCase().contains(query) ||
                empleado.id.toLowerCase().contains(query) ||
                empleado.puesto.toLowerCase().contains(query);
          }
        } else if (query.isEmpty) {
          matchesSearch = true;
        }

        // 2. Filtro por estado (Activo/Inactivo)
        bool matchesActivo = filtroActivoSeleccionado == null ||
            empleado.activo == filtroActivoSeleccionado;

        return matchesSearch && matchesActivo;
      }).toList();
    });
  }

  int get empleadosActivos => empleados.where((e) => e.activo).length;
  int get vacacionesPendientes => empleados.where((e) => e.activo).fold(0, (sum, e) => sum + e.vacacionesPendientes);

  String _getNombreCampo(String campo) {
    switch (campo) {
      case 'nombre':
        return 'Nombre';
      case 'id':
        return 'ID';
      case 'puesto':
        return 'Puesto';
      default:
        return '';
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? tempFiltroCampo = filtroCampoSeleccionado;
        bool? tempFiltroActivo = filtroActivoSeleccionado;

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
                          'Filtros de Personal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: PersonalScreen.textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempFiltroCampo = null;
                              tempFiltroActivo = null;
                            });
                          },
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text(
                      'Buscar por Campo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Selecciona en qué campo buscar por texto (si no seleccionas, buscará en todos)',
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
                          selectedColor: PersonalScreen.primaryColor.withOpacity(0.3),
                        ),
                        FilterChip(
                          label: const Text('ID'),
                          selected: tempFiltroCampo == 'id',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'id' : null;
                            });
                          },
                          selectedColor: PersonalScreen.primaryColor.withOpacity(0.3),
                        ),
                        FilterChip(
                          label: const Text('Puesto'),
                          selected: tempFiltroCampo == 'puesto',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'puesto' : null;
                            });
                          },
                          selectedColor: PersonalScreen.primaryColor.withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filtrar por Estado',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        FilterChip(
                          label: const Text('Activos'),
                          selected: tempFiltroActivo == true,
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroActivo = selected ? true : null;
                            });
                          },
                          selectedColor: Colors.green[200],
                        ),
                        FilterChip(
                          label: const Text('Inactivos'),
                          selected: tempFiltroActivo == false,
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroActivo = selected ? false : null;
                            });
                          },
                          selectedColor: Colors.orange[200],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filtroCampoSeleccionado = tempFiltroCampo;
                            filtroActivoSeleccionado = tempFiltroActivo;
                          });
                          _filterEmpleados();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PersonalScreen.primaryColor,
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

  void _agregarEmpleado() {
    // ... (Código de _agregarEmpleado)
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
    // ... (Código de _editarEmpleado)
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
    // ... (Código de _toggleEstadoEmpleado)
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

Future<void> _exportarAPDF() async {
  if (empleadosFiltrados.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay resultados para exportar')),
    );
    return;
  }

  try {
    // Solicitar permisos de almacenamiento
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se requieren permisos de almacenamiento')),
          );
          return;
        }
      }
    }

    // Crear el PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Reporte de Personal',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#06373E'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Total de resultados: ${empleadosFiltrados.length}',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  if (filtroActivoSeleccionado != null)
                    pw.Text(
                      'Filtro Estado: ${filtroActivoSeleccionado == true ? 'Activos' : 'Inactivos'}',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                    ),
                  pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#84B9BF')),
                ],
              ),
            ),
            
            // Tabla de Empleados
            _buildPdfTable(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    // Obtener el directorio de descargas
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }

    if (directory == null) {
      throw Exception('No se pudo acceder al directorio de almacenamiento');
    }

    // Crear nombre del archivo
    final timestamp = DateTime.now();
    final fileName = 'Reporte_Personal_${timestamp.day}-${timestamp.month}-${timestamp.year}_${timestamp.hour}-${timestamp.minute}.pdf';
    final file = File('${directory.path}/$fileName');

    // Guardar el archivo
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF guardado en: ${directory.path}/$fileName'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () async {
            await Printing.sharePdf(bytes: bytes, filename: fileName);
          },
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al exportar: $e')),
    );
  }
}
  pw.Widget _buildPdfTable() {
    // ... (Código de _buildPdfTable)
    const tableHeaders = ['ID', 'Nombre', 'Puesto', 'Sueldo (MXN)', 'Vacaciones', 'Estado'];

    return pw.Table.fromTextArray(
      headers: tableHeaders,
      data: empleadosFiltrados.map((empleado) {
        return [
          empleado.id,
          empleado.nombre,
          empleado.puesto,
          '\$${empleado.sueldo.toStringAsFixed(2)}',
          empleado.vacacionesPendientes.toString(),
          empleado.activo ? 'Activo' : 'Inactivo',
        ];
      }).toList(),
      border: pw.TableBorder.all(color: PdfColor.fromHex('#84B9BF')),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF84B9BF)),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
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
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0, // Altura adecuada para incluir estadísticas
            backgroundColor: PersonalScreen.primaryColor,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
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
                color: PersonalScreen.primaryColor,
                // Reducir el padding inferior para dar más espacio
                padding: const EdgeInsets.only(top: 40, bottom: 40, left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Personal',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Gestión de Recursos Humanos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Stats en la AppBar expandida
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                          const SizedBox(width: 8)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: PersonalScreen.accentColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildExportButton(),
                  ),
                  // Eliminamos el SizedBox(height: 20) después del botón de exportar
                  // para reducir el espacio si es necesario, pero lo mantenemos al final.
                  const SizedBox(height: 20), 
                  _buildEmpleadosList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget de estadísticas reutilizado con ajustes para evitar overflow
  Widget _buildStatContainer(String label, String value, Color bgColor) {
    return Container(
      // Padding vertical ligeramente reducido
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), 
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.9),
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
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: PersonalScreen.textColor,
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Se mueve el ajuste de la posición a la barra de búsqueda y exportación
  Widget _buildSearchBar() {
    return Container(
      // Ajuste de traslación para superponer en el área del AppBar
      transform: Matrix4.translationValues(0.0, 10.0, 0.0), // Ajustado de -24.0 a -32.0 para subirlo más
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
                    ? "Buscar por nombre, ID o puesto..." 
                    : "Buscar en ${_getNombreCampo(filtroCampoSeleccionado!)}...",
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: PersonalScreen.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: filtroCampoSeleccionado != null || filtroActivoSeleccionado != null
                  ? PersonalScreen.primaryColor
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
                color: filtroCampoSeleccionado != null || filtroActivoSeleccionado != null
                    ? Colors.white
                    : PersonalScreen.primaryColor,
                size: 28,
              ),
              onPressed: _mostrarFiltros,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      // Ajuste de traslación para superponer en el área del AppBar
      transform: Matrix4.translationValues(0.0, 10.0, 0.0), 
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _exportarAPDF,
        icon: const Icon(Icons.picture_as_pdf, size: 20),
        label: const Text(
          'Exportar resultados a PDF',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: PersonalScreen.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
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
    // ... (El resto de _buildEmployeeCard se mantiene igual)
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: empleado.activo ? Colors.white : PersonalScreen.accentColor,
          borderRadius: BorderRadius.circular(16),
          border: empleado.activo ? null : Border.all(color: Colors.orange.shade300, width: 1),
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