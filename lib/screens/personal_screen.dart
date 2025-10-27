import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text("Pantalla de Personal", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
