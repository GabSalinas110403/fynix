import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';

class FinanzasScreen extends StatelessWidget {
  const FinanzasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finanzas"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text("Pantalla de Finanzas", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
