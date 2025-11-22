import 'package:flutter/material.dart';

// Definición de colores para el estilo visual consistente
const Color primaryColor = Color(0xFF84B9BF);
const Color textColor = Color(0xFF06373E); 

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  // bottomContent es opcional y se usa para pasar las estadísticas (Personal) 
  // o los botones de acción (Proveedores/Finanzas).
  final Widget? bottomContent; 

  const CustomHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Ajustamos el padding inferior. Es mayor si hay 'bottomContent'
      padding: EdgeInsets.only(bottom: bottomContent == null ? 25 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- 1. Fila de Íconos (Menú y Notificaciones) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                // Botón de Menú (Abre el CustomDrawer)
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
                      const SnackBar(content: Text('Notificaciones')),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          // --- 2. Título Principal ---
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          
          // --- 3. Subtítulo ---
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          
          // --- 4. Contenido Inferior (Opcional: Stats o Botones) ---
          if (bottomContent != null) ...[
            const SizedBox(height: 20),
            bottomContent!,
          ],
        ],
      ),
    );
  }
}