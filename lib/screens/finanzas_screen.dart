import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NECESARIO PARA PERSISTENCIA
import 'dart:convert'; // NECESARIO PARA JSON
import '../widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart'; // IMPORTAR EL WIDGET DE NOTIFICACIONES
import 'home_screen.dart'; // IMPORTAR PARA ACCEDER A LA CLASE Task

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  List<Map<String, dynamic>> registros = [];
  List<Task> allTasks = []; // LISTA DE TAREAS PARA LAS NOTIFICACIONES

  @override
  void initState() {
    super.initState();
    _loadTasks(); // CARGAR TAREAS AL INICIAR
  }

  // CARGAR TAREAS DESDE SharedPreferences (igual que en home_screen)
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

  void _abrirModal(bool esIngreso) {
    final TextEditingController nombreCtrl = TextEditingController();
    final TextEditingController cantidadCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(esIngreso ? "Nuevo Ingreso" : "Nuevo Gasto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                  labelText: esIngreso
                      ? "Nombre del ingreso"
                      : "Nombre del gasto",
                ),
              ),
              TextField(
                controller: cantidadCtrl,
                decoration: const InputDecoration(labelText: "Cantidad (MXN)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                String nombre = nombreCtrl.text.trim();
                double? cantidad = double.tryParse(cantidadCtrl.text);

                if (nombre.isEmpty || cantidad == null) return;

                setState(() {
                  registros.add({
                    "tipo": esIngreso ? "ingreso" : "gasto",
                    "nombre": nombre,
                    "cantidad": cantidad,
                    "fecha": DateTime.now(),
                  });
                });

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _generarSpots() {
    final sorted = List<Map<String, dynamic>>.from(registros)
      ..sort((a, b) => a["fecha"].compareTo(b["fecha"]));

    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;

      double cantidad = e["cantidad"].toDouble();
      double y = e["tipo"] == "ingreso" ? cantidad : -cantidad;

      return FlSpot(index.toDouble(), y);
    }).toList();
  }

  double get totalIngresos => registros
      .where((e) => e["tipo"] == "ingreso")
      .fold(0.0, (s, e) => s + e["cantidad"]);

  double get totalGastos => registros
      .where((e) => e["tipo"] == "gasto")
      .fold(0.0, (s, e) => s + e["cantidad"]);

  @override
  Widget build(BuildContext context) {
    final String fechaHoy = DateFormat(
      'dd MMM yyyy',
      'es',
    ).format(DateTime.now());

    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: const Color(0xFF84B9BF),
                padding: const EdgeInsets.only(bottom: 25, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          const Spacer(),
                          // USAR EL WIDGET NotificationIcon REUTILIZABLE
                          NotificationIcon(allTasks: allTasks),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    const Text(
                      'Finanzas',
                      style: TextStyle(
                        color: Color(0xFFDEDEDE),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Registro y gestión',
                      style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 16),
                    ),

                    const SizedBox(height: 15),

                    // Botones con modal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _abrirModal(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF06373E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('+ Nuevo Ingreso'),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () => _abrirModal(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF06373E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('+ Nuevo Gasto'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Panel de información dinamico
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ingresos Totales',
                          style: TextStyle(
                            color: Color(0xFF06373E),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total Restante',
                          style: TextStyle(
                            color: Color(0xFF06373E),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${totalIngresos.toStringAsFixed(2)} MXN',
                          style: const TextStyle(
                            color: Color(0xFF06373E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${(totalIngresos - totalGastos).toStringAsFixed(2)} MXN',
                          style: const TextStyle(
                            color: Color(0xFF06373E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Gastos Totales',
                      style: TextStyle(color: Color(0xFF06373E), fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$${totalGastos.toStringAsFixed(2)} MXN',
                      style: const TextStyle(
                        color: Color(0xFF06373E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Lista dinámica de registros
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fechaHoy,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ...registros.reversed.map(
                      (e) => Column(
                        children: [
                          _buildItem(
                            e["nombre"],
                            (e["tipo"] == "ingreso" ? "+ " : "- ") +
                                "\$${e["cantidad"].toStringAsFixed(2)}",
                            e["tipo"] == "ingreso"
                                ? const Color(0xFF06373E)
                                : const Color(0xFFE1EDE9),
                            e["tipo"] == "ingreso"
                                ? Colors.white
                                : Colors.black87,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Gráfica dinámica
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                height: 220,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generarSpots(),
                        isCurved: true,
                        color: const Color(0xFF84B9BF),
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF84B9BF).withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String nombre, String monto, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nombre,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            monto,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}