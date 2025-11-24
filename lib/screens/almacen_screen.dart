import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fynix/widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart';
import 'home_screen.dart';

class AlmacenScreen extends StatefulWidget {
  const AlmacenScreen({super.key});

  static const Color headerColor = Color(0xFF84B9BF);
  static const Color listBackgroundColor = Color(0xFFE0F2F1);
  static const Color accentGreen = Color(0xFF5B9E9E);

  @override
  State<AlmacenScreen> createState() => _AlmacenScreenState();
}

class _AlmacenScreenState extends State<AlmacenScreen> {
  List<Task> allTasks = [];
  List<Product> products = [];
  List<Product> productsFiltrados = [];
  TextEditingController searchController = TextEditingController();

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
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        productsFiltrados = List.from(products);
      } else {
        productsFiltrados = products.where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query);
        }).toList();
      }
    });
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
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
              color: AlmacenScreen.listBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  ProfitMarginChart(products: productsFiltrados),
                  const SizedBox(height: 30),
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
    return Container(
      transform: Matrix4.translationValues(0.0, 8.0, 0.0),
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
                  hintText: "Buscar",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: AlmacenScreen.headerColor),
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
              icon: const Icon(Icons.filter_list, color: AlmacenScreen.headerColor, size: 28),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtros próximamente')),
                );
              },
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.date,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      "SKU: ${product.sku}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AlmacenScreen.headerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      "Stock: ${product.stock}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: product.stock < 50
                            ? Colors.red.shade700
                            : AlmacenScreen.headerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FinanceDetail(
                  label: "Costo",
                  value: "\$${product.cost.toStringAsFixed(0)} MXN",
                  color: Colors.black54,
                ),
                _FinanceDetail(
                  label: "Venta",
                  value: "\$${product.sale.toStringAsFixed(0)} MXN",
                  color: AlmacenScreen.accentGreen,
                ),
                _FinanceDetail(
                  label: "Ganancia",
                  value: "\$${product.profit.toStringAsFixed(0)} MXN",
                  color: AlmacenScreen.accentGreen,
                ),
                _FinanceDetail(
                  label: "Margen",
                  value: "${product.margin.toStringAsFixed(2)}%",
                  color: AlmacenScreen.accentGreen,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinanceDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _FinanceDetail({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfitMarginChart extends StatelessWidget {
  final List<Product> products;

  const ProfitMarginChart({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Margen de Ganancia por Producto",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: BoxConstraints(
                maxHeight: products.length * 55.0,
              ),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
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
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
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
                                  color: AlmacenScreen.accentGreen.withOpacity(0.7),
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
    );
  }
}