import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart';

class ProveedoresScreen extends StatelessWidget {
  const ProveedoresScreen({super.key});

  // Reutilizamos las constantes de color de PersonalScreen para mantener la consistencia visual
  static const Color primaryColor = Color(0xFF84B9BF); // Verde/Azul Fuerte (Header)
  static const Color accentColor = Color(0xFFE1EDE9); // Verde claro/Crema (Fondo de Cards/Body)
  static const Color textColor = Color(0xFF06373E); // Color de texto oscuro
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Container(
        // Aplicamos el mismo gradiente de fondo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              accentColor, 
            ],
            stops: [0.3, 0.3], // Mismo punto de corte
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. Encabezado Personalizado (con botón de Agregar) ---
                _buildCustomHeader(context),
                
                // --- 2. Barra de Búsqueda y Filtro (Reutilizada) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const SearchAndFilterBar(), 
                ),

                const SizedBox(height: 20),

                // --- 3. Lista de Proveedores ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildProveedorCard('15 sep 2025', 'Suministros Tecnológicos del Norte S.A. de C.V.', 'PRO-001', 'Suministros de Papel de oficina, tóner para impresoras, productos de limpieza.'),
                      _buildProveedorCard('10 oct 2025', 'Mobiliario Fénix Express S. de R.L.', 'PRO-002', 'Escritorios ergonómicos, sillas de oficina y archivadores metálicos.'),
                      _buildProveedorCard('22 nov 2025', 'Servicios de Internet Ultra', 'PRO-003', 'Servicio de Internet de alta velocidad y telefonía IP para oficinas.'),
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

  // Modificación del encabezado para Proveedores (sin stats, con botón)
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50), // Más padding inferior para dar espacio al transform de la barra
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
                      const SnackBar(content: Text('Notificaciones de Proveedores')),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          // Título principal
          const Text(
            'Proveedores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Subtítulo
          const Text(
            'Gestión de Proveedores',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 20),

          // Botón principal de acción
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agregar Proveedor')),
              );
            },
            icon: const Icon(Icons.add, color: primaryColor),
            label: const Text(
              '+ Proveedores',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para la tarjeta de cada proveedor en la lista
  Widget _buildProveedorCard(
      String date, String name, String id, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Usamos blanco para que resalte sobre accentColor
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
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
            Text(
              'ID: $id',
              style: const TextStyle(color: textColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// REUTILIZACIÓN DE LA BARRA DE BÚSQUEDA (SE DEFINE AQUÍ PARA EVITAR PROBLEMAS DE ARCHIVOS)
// -----------------------------------------------------------------------------

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  // Usamos el color primario de ProveedoresScreen como referencia para los íconos
  static const Color iconColor = ProveedoresScreen.primaryColor; 

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
                  icon: Icon(Icons.search, color: iconColor), 
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
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