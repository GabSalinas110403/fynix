import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';

class AlmacenScreen extends StatelessWidget {
  const AlmacenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Almacén"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text("Pantalla de Almacén", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
