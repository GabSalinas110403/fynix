import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fynix/widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart';
import 'home_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AlmacenScreen extends StatefulWidget {
  const AlmacenScreen({super.key});

  static const Color headerColor = Color(0xFF84B9BF);
  static const Color listBackgroundColor = Color(0xFFE0F2F1);
  static const Color accentGreen = Color(0xFF5B9E9E);
  static const Color textColor = Color(0xFF06373E); 

  @override
  State<AlmacenScreen> createState() => _AlmacenScreenState();
}

class _AlmacenScreenState extends State<AlmacenScreen> {
  List<Task> allTasks = [];
  List<Product> products = [];
  List<Product> productsFiltrados = [];
  TextEditingController searchController = TextEditingController();

  // --- Filtros avanzados ---
  String? filtroCampoSeleccionado; // 'name', 'sku'
  String? filtroMesSeleccionado;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _initializeProducts();
    searchController.addListener(_filterProducts);
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

  void _initializeProducts() {
    products = [
      Product(
        date: "15 sep 2025",
        name: "Laptop",
        sku: "LPT-001",
        cost: 12000,
        sale: 15000,
        stock: 45,
      ),
      Product(
        date: "14 sep 2025",
        name: "Celular",
        sku: "CLR-001",
        cost: 10000,
        sale: 12500,
        stock: 120,
      ),
      Product(
        date: "10 sep 2025",
        name: "Tablet",
        sku: "TBL-001",
        cost: 8000,
        sale: 11000,
        stock: 30,
      ),
    ];
    productsFiltrados = List.from(products);
  }

  void _filterProducts() {
    String query = searchController.text.toLowerCase().trim();
    setState(() {
      productsFiltrados = products.where((product) {
        // Filtro de búsqueda por texto según el campo seleccionado
        bool matchesSearch = query.isEmpty;

        if (!matchesSearch && query.isNotEmpty) {
          if (filtroCampoSeleccionado == null) {
            // Si no hay campo seleccionado, buscar en Nombre y SKU
            matchesSearch = product.name.toLowerCase().contains(query) ||
                product.sku.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'name') {
            matchesSearch = product.name.toLowerCase().contains(query);
          } else if (filtroCampoSeleccionado == 'sku') {
            matchesSearch = product.sku.toLowerCase().contains(query);
          }
        } else {
          matchesSearch = true;
        }

        // Filtro por mes de registro (fecha)
        bool matchesMes = true;
        if (filtroMesSeleccionado != null) {
          matchesMes = product.date.toLowerCase().contains(filtroMesSeleccionado!.toLowerCase());
        }

        return matchesSearch && matchesMes;
      }).toList();
    });
  }

  // Función para obtener el nombre legible del campo de filtro
  String _getNombreCampo(String campo) {
    switch (campo) {
      case 'name':
        return 'Nombre';
      case 'sku':
        return 'SKU';
      default:
        return '';
    }
  }
  
  // Implementación del ModalBottomSheet para filtros
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
                            color: AlmacenScreen.textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempFiltroCampo = null;
                              tempFiltroMes = null;
                            });
                          },
                          child: const Text('Limpiar', style: TextStyle(color: AlmacenScreen.headerColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Buscar por Campo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlmacenScreen.textColor),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Selecciona en qué campo buscar (si no seleccionas, buscará en Nombre y SKU)',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        FilterChip(
                          label: const Text('Nombre'),
                          selected: tempFiltroCampo == 'name',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'name' : null;
                            });
                          },
                          selectedColor: AlmacenScreen.headerColor.withOpacity(0.3),
                        ),
                        FilterChip(
                          label: const Text('SKU'),
                          selected: tempFiltroCampo == 'sku',
                          onSelected: (selected) {
                            setModalState(() {
                              tempFiltroCampo = selected ? 'sku' : null;
                            });
                          },
                          selectedColor: AlmacenScreen.headerColor.withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filtrar por Mes de Registro',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlmacenScreen.textColor),
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
                          selectedColor: AlmacenScreen.headerColor.withOpacity(0.5),
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
                          _filterProducts();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AlmacenScreen.headerColor,
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

  // Función de exportar a PDF (actualizada para incluir filtros)
  Future<void> _exportToPDF() async {
    if (productsFiltrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay resultados para exportar')),
      );
      return;
    }
    
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
                    'Reporte de Almacén',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#84B9BF'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Fecha de generación: ${_formatDate(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  if (filtroCampoSeleccionado != null || filtroMesSeleccionado != null) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Filtros aplicados:',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    if (filtroCampoSeleccionado != null)
                      pw.Text(
                        '• Campo: ${_getNombreCampo(filtroCampoSeleccionado!)}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    if (filtroMesSeleccionado != null)
                      pw.Text(
                        '• Mes: ${filtroMesSeleccionado!.toUpperCase()}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                  ],
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Total de resultados: ${productsFiltrados.length}',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Divider(thickness: 2, color: PdfColor.fromHex('#84B9BF')),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Tabla de Productos
            pw.Text(
              'Resumen de Productos',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            pw.Table.fromTextArray(
              headers: ['Producto', 'SKU', 'Stock', 'Costo', 'Venta', 'Ganancia', 'Margen'],
              data: productsFiltrados.map((product) {
                return [
                  product.name,
                  product.sku,
                  product.stock.toString(),
                  '\$${product.cost.toStringAsFixed(0)}',
                  '\$${product.sale.toStringAsFixed(0)}',
                  '\$${product.profit.toStringAsFixed(0)}',
                  '${product.margin.toStringAsFixed(2)}%',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 30),
            // Estadísticas (se mantienen igual)
            pw.Text(
              'Estadísticas',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Total de productos: ${productsFiltrados.length}'),
            pw.Text(
              'Stock total: ${productsFiltrados.fold<int>(0, (sum, p) => sum + p.stock)}',
            ),
            pw.Text(
              'Valor total en inventario: \$${productsFiltrados.fold<double>(0, (sum, p) => sum + (p.cost * p.stock)).toStringAsFixed(0)} MXN',
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Almacen_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  void _agregarProducto() {
    final nombreController = TextEditingController();
    final skuController = TextEditingController();
    final costoController = TextEditingController();
    final ventaController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock (Cantidad)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: costoController,
                decoration: const InputDecoration(
                  labelText: 'Costo (MXN)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: ventaController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Venta (MXN)',
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
                  skuController.text.trim().isEmpty) return;

              double costo = double.tryParse(costoController.text) ?? 0.0;
              double venta = double.tryParse(ventaController.text) ?? 0.0;
              int stock = int.tryParse(stockController.text) ?? 0;

              setState(() {
                products.add(
                  Product(
                    date: _formatDate(DateTime.now()),
                    name: nombreController.text.trim(),
                    sku: skuController.text.trim().toUpperCase(),
                    cost: costo,
                    sale: venta,
                    stock: stock,
                  ),
                );
                _filterProducts();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto agregado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AlmacenScreen.accentGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarProducto(Product product) async {
    final nombreController = TextEditingController(text: product.name);
    final skuController = TextEditingController(text: product.sku);
    final costoController = TextEditingController(text: product.cost.toStringAsFixed(0));
    final ventaController = TextEditingController(text: product.sale.toStringAsFixed(0));
    final stockController = TextEditingController(text: product.stock.toString());

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Editar Producto: ${product.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre del Producto",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(
                  labelText: "SKU",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: "Stock (Cantidad en Almacén)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: costoController,
                decoration: const InputDecoration(
                  labelText: "Costo (MXN)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: ventaController,
                decoration: const InputDecoration(
                  labelText: "Precio de Venta (MXN)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Borrar Producto', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(dialogContext).pop('DELETE');
            },
          ),
          const Spacer(),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(dialogContext).pop('CANCEL');
            },
          ),
          ElevatedButton(
            child: const Text('Guardar Cambios'),
            onPressed: () {
              try {
                final newCost = double.parse(costoController.text);
                final newSale = double.parse(ventaController.text);
                final newStock = int.parse(stockController.text);

                setState(() {
                  int index = products.indexWhere((p) => p.sku == product.sku);
                  if (index != -1) {
                    products[index] = Product(
                      date: product.date,
                      name: nombreController.text.trim(),
                      sku: skuController.text.trim().toUpperCase(),
                      cost: newCost,
                      sale: newSale,
                      stock: newStock,
                    );
                    _filterProducts();
                  }
                });
                Navigator.of(dialogContext).pop('SAVED');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: Asegúrate de que los campos sean números válidos.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AlmacenScreen.accentGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == 'DELETE') {
      setState(() {
        products.removeWhere((p) => p.sku == product.sku);
        _filterProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto ${product.name} (SKU: ${product.sku}) eliminado.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } else if (result == 'SAVED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado con éxito.'),
          backgroundColor: AlmacenScreen.accentGreen,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
            backgroundColor: AlmacenScreen.headerColor,
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
                color: AlmacenScreen.headerColor,
                padding: const EdgeInsets.only(top: 80, bottom: 20, left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Almacén',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Productos y costos de producción',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _agregarProducto,
                          icon: const Icon(Icons.add, color: AlmacenScreen.headerColor),
                          label: const Text(
                            "Nuevo Producto",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AlmacenScreen.headerColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AlmacenScreen.listBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildSearchBarAndFilter(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildExportButton(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfitMarginChart(products: productsFiltrados),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            "Productos en Almacén",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildProductsList(),
                      ],
                    ),
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

  // --- Widget de Barra de Búsqueda y Filtros ---
  Widget _buildSearchBarAndFilter() {
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
                    icon: const Icon(Icons.search, color: AlmacenScreen.headerColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: filtroCampoSeleccionado != null || filtroMesSeleccionado != null
                    ? AlmacenScreen.headerColor
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
                      : AlmacenScreen.headerColor, 
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

  // --- Widget del Botón de Exportar a PDF ---
  Widget _buildExportButton() {
    return Container(
      transform: Matrix4.translationValues(0.0, 6.0, 0.0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _exportToPDF,
        icon: const Icon(Icons.picture_as_pdf, size: 20),
        label: const Text(
          'Exportar resultados a PDF',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AlmacenScreen.headerColor,
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

  Widget _buildProductsList() {
    if (productsFiltrados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron productos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: productsFiltrados.map((product) {
        return ProductCard(
          product: product,
          onEdit: () => _editarProducto(product),
        );
      }).toList(),
    );
  }
}

class Product {
  final String date;
  final String name;
  final String sku;
  final double cost;
  final double sale;
  final int stock;

  Product({
    required this.date,
    required this.name,
    required this.sku,
    required this.cost,
    required this.sale,
    required this.stock,
  });

  double get profit => sale - cost;
  double get margin => cost > 0 ? (profit / sale) * 100 : 0;
}

// ==========================================================
// CLASE MODIFICADA: Se eliminan las filas de Ganancia y Margen.
// ==========================================================
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "SKU: ${product.sku}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AlmacenScreen.headerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.stock < 50
                            ? Colors.red.shade50
                            : AlmacenScreen.headerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Stock: ${product.stock}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: product.stock < 50
                              ? Colors.red.shade700
                              : AlmacenScreen.headerColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // --- Solo se deja Costo y Venta ---
                Row(
                  children: [
                    Expanded(
                      child: _CompactFinanceInfo(
                        label: "Costo",
                        value: "\$${product.cost.toStringAsFixed(0)}",
                        color: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: _CompactFinanceInfo(
                        label: "Venta",
                        value: "\$${product.sale.toStringAsFixed(0)}",
                        color: AlmacenScreen.accentGreen,
                      ),
                    ),
                  ],
                ),
                // --- Se eliminaron las filas de Ganancia y Margen ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactFinanceInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _CompactFinanceInfo({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class ProfitMarginChart extends StatefulWidget {
  final List<Product> products;

  const ProfitMarginChart({super.key, required this.products});

  @override
  State<ProfitMarginChart> createState() => _ProfitMarginChartState();
}

class _ProfitMarginChartState extends State<ProfitMarginChart> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Margen de Ganancia",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    _isExpanded 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    color: AlmacenScreen.headerColor,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: widget.products.length * 55.0,
                    ),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        final product = widget.products[index];
                        final barValue = product.margin / 100;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  "${product.name}\nSKU: ${product.sku.length > 7 ? product.sku.substring(4) : product.sku}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: AlmacenScreen.listBackgroundColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5 *
                                          barValue.clamp(0.0, 1.0),
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: AlmacenScreen.accentGreen
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      child: Text(
                                        "${product.margin.toStringAsFixed(0)}%",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}