import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  // Colores principales de la aplicación basados en las imágenes proporcionadas
  static const Color primaryColor = Color(0xFF84B9BF); // Verde/Azul Fuerte (Header)
  static const Color accentColor = Color(0xFFE1EDE9); // Verde claro/Crema (Fondo de Cards/Body)
  static const Color textColor = Color(0xFF06373E); // Color de texto oscuro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El drawer va al nivel del Scaffold
      drawer: const CustomDrawer(),
      // Usamos Body y Container para aplicar el diseño de fondo y encabezado
      body: Container(
        // Aplicamos el gradiente de dos colores: Fuerte arriba, Claro abajo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              accentColor, 
            ],
            // Define dónde termina el color primario (aprox. 30% del alto)
            stops: [0.3, 0.3], 
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. Encabezado Personalizado (Menu, Notificación, Título) ---
                _buildCustomHeader(context),
                
                // --- 2. Barra de Búsqueda y Filtro ---
                // Nota: El SizedBox(height: 15) se puede ajustar si el transform lo compensa demasiado.
                // La clase SearchAndFilterBar ya aplica un transform de 18.0.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // Utilizamos directamente la clase que incluye la lógica de transformación
                  child: const SearchAndFilterBar(), 
                ),

                const SizedBox(height: 20),

                // --- 3. Lista de Empleados (Replica de las cards) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildEmployeeCard('ID EMPLEADO', 'Nombre de empleado', 'Gerente', '10,000 MXN'),
                      _buildEmployeeCard('ID EMPLEADO', 'Nombre de empleado', 'Gerente', '10,000 MXN'),
                      _buildEmployeeCard('ID EMPLEADO', 'Nombre de empleado', 'Gerente', '10,000 MXN'),
                      _buildEmployeeCard('ID EMPLEADO', 'Nombre de empleado', 'Gerente', '10,000 MXN'),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el Título, Menú y Notificación
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row para el botón de menú y notificaciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                // Botón de Menú
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Spacer(),
                // Botón de Notificaciones
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('NO SIRVE AAAUN')),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          // Título principal
          const Text(
            'Personal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Subtítulo
          const Text(
            'Gestión de Recursos Humanos',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 20),

          // Contenedores de estadísticas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatContainer('Empleados activos:', '15', Colors.white),
                _buildStatContainer('Vacaciones pendientes:', '2', Colors.white),
                _buildStatContainer('Próximos eventos:', '1', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget de un solo contenedor de estadística
  Widget _buildStatContainer(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Se mantiene como una función simple que devuelve el widget
  Widget _buildSearchBar() {
    return const SearchAndFilterBar();
  }

  // Widget para la tarjeta de cada empleado en la lista
  Widget _buildEmployeeCard(
      String id, String name, String position, String salary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 254, 254, 254), // Usamos el color claro para el fondo de las tarjetas
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: const TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Puesto: $position',
                    style: const TextStyle(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sueldo: $salary',
                    style: const TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.groups, 
              size: 50,
              color: primaryColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// Se debe definir fuera de la clase PersonalScreen o en un archivo aparte (widgets/search_filter_bar.dart)
class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  // Usamos el color primario de PersonalScreen como referencia para los íconos
  static const Color iconColor = PersonalScreen.primaryColor; 

  @override
  Widget build(BuildContext context) {
    return Container(
      // Efecto de levantamiento
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Buscar . . .",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  // Se reemplazó ReportesScreen.headerColor por iconColor (PrimaryColor)
                  icon: Icon(Icons.search, color: iconColor), 
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            // Se reemplazó ReportesScreen.headerColor por iconColor (PrimaryColor)
            icon: const Icon(Icons.filter_list, color: iconColor, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrir filtro aca')),
              );
            },
          ),
        ],
      ),
    );
  }
}