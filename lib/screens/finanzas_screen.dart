import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_drawer.dart'; // asegúrate de importar tu drawer

class FinanzasScreen extends StatelessWidget {
  const FinanzasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String fechaHoy = DateFormat(
      'dd MMM yyyy',
      'es',
    ).format(DateTime(2025, 10, 27));

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
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                           
                            },
                          ),
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

                    // Botones centrados
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
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
                          onPressed: () {},
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

              // 🟩 Container de información
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$15,000 MXN',
                          style: TextStyle(
                            color: Color(0xFF06373E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '+\$7,650 MXN',
                          style: TextStyle(
                            color: Color(0xFF06373E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Gastos Totales',
                      style: TextStyle(color: Color(0xFF06373E), fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '\$7,350 MXN',
                      style: TextStyle(
                        color: Color(0xFF06373E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🟩 Container de registros
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
                    // Fecha y total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fechaHoy,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '+7,650 MXN',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Lista de items
                    _buildItem(
                      'Laptop',
                      '+\$15,000',
                      const Color(0xFF06373E),
                      Colors.white,
                    ),
                    const SizedBox(height: 10),
                    _buildItem(
                      'Celular',
                      '-\$5,000',
                      const Color(0xFFE1EDE9),
                      Colors.black87,
                    ),
                    const SizedBox(height: 10),
                    _buildItem(
                      'Electricidad',
                      '-\$2,350',
                      const Color(0xFFE1EDE9),
                      Colors.black87,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🟩 Gráfica
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
                        spots: [
                          FlSpot(0, 400),
                          FlSpot(2, 600),
                          FlSpot(4, 800),
                          FlSpot(6, 300),
                          FlSpot(8, 700),
                        ],
                        isCurved: true,
                        color: const Color(0xFF84B9BF),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
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

  // 🟩 Widget para los rectángulos de items
  static Widget _buildItem(
    String nombre,
    String monto,
    Color color,
    Color textColor,
  ) {
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