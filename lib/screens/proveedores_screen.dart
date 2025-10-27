import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';

class ProveedoresScreen extends StatelessWidget {
  const ProveedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proveedores"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text("Pantalla de Proveedores", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
