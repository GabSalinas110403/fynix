import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // Colores definidos según el prototipo
  static const Color accentColor = Color(0xFF004D40); // Color principal para texto e indicadores
  static const Color selectedBgColor = Color(0xFFB2DFDB); // Fondo del día seleccionado

  // Simulación de los datos del calendario (puedes adaptarlo para usar fechas reales)
  final List<Map<String, dynamic>> _weekDays = [
    {'dayName': 'Dom', 'date': 3, 'isSelected': false},
    {'dayName': 'Lun', 'date': 4, 'isSelected': true}, // Día inicial seleccionado
    {'dayName': 'Mar', 'date': 5, 'isSelected': false},
    {'dayName': 'Mie', 'date': 6, 'isSelected': false},
    {'dayName': 'Jue', 'date': 7, 'isSelected': false},
    {'dayName': 'Vie', 'date': 8, 'isSelected': false},
    {'dayName': 'Sab', 'date': 9, 'isSelected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Encabezado del Calendario (Íconos y Título)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.apps, color: accentColor),
              const Text(
                "Calendario",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Lógica para el botón de añadir (+)
                },
                child: const Icon(Icons.add_circle_outline, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height:20),

          // 2. Lista de Días de la Semana (Scrollable Horizontal)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 80, // Altura fija para la lista de días
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _weekDays.length,
                itemBuilder: (context, index) {
                  final day = _weekDays[index];
                  final isSelected = day['isSelected'] as bool;
            
                  return GestureDetector(
                    onTap: () {
                      // Lógica para cambiar la selección
                      setState(() {
                        // Deseleccionar el anterior
                        for (var item in _weekDays) {
                          item['isSelected'] = false;
                        }
                        // Seleccionar el nuevo
                        day['isSelected'] = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 48, // Ancho de cada "pastilla" de día
                      decoration: BoxDecoration(
                        color: isSelected ? selectedBgColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? selectedBgColor : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Nombre del día (Dom, Lun, etc.)
                          Text(
                            day['dayName'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? accentColor : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Fecha del día (03, 04, etc.)
                          Text(
                            day['date'].toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? accentColor : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Indicador de selección (el punto verde)
                          if (isSelected)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (!isSelected) const SizedBox(height: 6), // Espacio para alinear
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Fecha actual mostrada debajo de la barra
          Text(
            "05 de Septiembre 2025", // Hardcodeado según el prototipo
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}