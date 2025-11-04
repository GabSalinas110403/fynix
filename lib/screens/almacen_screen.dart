import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart'; 

class AlmacenScreen extends StatelessWidget {
  const AlmacenScreen({super.key});

  static const Color headerColor = Color(0xFF84B9BF);
  static const Color listBackgroundColor = Color(0xFFE0F2F1);
  static const Color accentGreen = Color(0xFF5B9E9E);

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
            backgroundColor: headerColor,

            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 30),
                onPressed: () {
                },
              ),
              const SizedBox(width: 8),
            ], 
            
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(),
              background: Container(
                color: headerColor,
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abriendo formulario de nuevo producto...')),
                        );
                      },
                      icon: const Icon(Icons.add, color: headerColor),
                      label: const Text(
                        "Nuevo Producto",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: headerColor,
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
              color: listBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchAndFilterBar(),
                  SizedBox(height: 10),
                  
                  ProfitMarginChart(), 
                  SizedBox(height: 30),
                  
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      "Productos en Almacén",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),

                  ProductList(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  WIDGETS REUTILIZABLES (Segun yo)

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Buscar",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: AlmacenScreen.headerColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AlmacenScreen.headerColor, size: 30),
            onPressed: () {
      
            },
          ),
        ],
      ),
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

  Product copyWith({
    String? date,
    String? name,
    String? sku,
    double? cost,
    double? sale,
    int? stock,
  }) {
    return Product(
      date: date ?? this.date,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      cost: cost ?? this.cost,
      sale: sale ?? this.sale,
      stock: stock ?? this.stock,
    );
  }

  double get profit => sale - cost;
  double get margin => (profit / sale) * 100;
}

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  static final List<Product> products = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products.map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: ProductCard(product: product),
        );
      }).toList(),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  void _editProduct(BuildContext context) async {
    final result = await showDialog<Product?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ProductEditDialog(product: product);
      },
    );

    if (result == null) {
      return;
    }

    if (result.name == 'DELETE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulación: Producto ${product.name} (SKU: ${product.sku}) ha sido ELIMINADO.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Simulación: Producto ${result.name} (Stock: ${result.stock}) actualizado con éxito.',
          ),
          backgroundColor: AlmacenScreen.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _editProduct(context),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlmacenScreen.headerColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row( 
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    "Stock: ${product.stock}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: product.stock < 50 ? Colors.red.shade700 : AlmacenScreen.headerColor,
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
  const ProfitMarginChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> products = ProductList.products;
    
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final barValue = product.margin / 100; 

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            "${product.name}\nSKU: ${product.sku.substring(4)}",
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
                                width: MediaQuery.of(context).size.width * 0.5 * barValue,
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


class ProductEditDialog extends StatefulWidget {
  final Product product;

  const ProductEditDialog({
    super.key,
    required this.product,
  });

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _costController;
  late TextEditingController _saleController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _skuController = TextEditingController(text: widget.product.sku);
    _costController = TextEditingController(text: widget.product.cost.toStringAsFixed(0));
    _saleController = TextEditingController(text: widget.product.sale.toStringAsFixed(0));
    _stockController = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costController.dispose();
    _saleController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Product? _trySaveProduct() {
    try {
      final newCost = double.parse(_costController.text);
      final newSale = double.parse(_saleController.text);
      final newStock = int.parse(_stockController.text);

      return widget.product.copyWith(
        name: _nameController.text,
        sku: _skuController.text,
        cost: newCost,
        sale: newSale,
        stock: newStock,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Asegúrate de que los campos Costo, Venta y Stock sean números válidos.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Editar Producto: ${widget.product.name}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nombre del Producto"),
            ),
            TextField(
              controller: _skuController,
              decoration: const InputDecoration(labelText: "SKU"),
            ),
            
            const SizedBox(height: 15),

            TextField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: "Stock (Cantidad en Almacén)"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: _costController,
              decoration: const InputDecoration(labelText: "Costo (\$ MXN)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _saleController,
              decoration: const InputDecoration(labelText: "Precio de Venta (\$ MXN)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Borrar Producto', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop(widget.product.copyWith(name: 'DELETE'));
          },
        ),

        const Spacer(),

        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(null); 
          },
        ),
        ElevatedButton(
          child: const Text('Guardar Cambios'),
          onPressed: () {
            final updatedProduct = _trySaveProduct();
            if (updatedProduct != null) {
              Navigator.of(context).pop(updatedProduct);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AlmacenScreen.accentGreen,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}