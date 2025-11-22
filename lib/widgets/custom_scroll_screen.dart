import 'package:flutter/material.dart';

class CustomScrollScreen extends StatelessWidget {
  // Los elementos que pueden cambiar por pantalla
  final String title;
  final Widget? drawer;
  final List<Widget> actions;
  final Widget bodyContent;
  final Color headerColor;
  final Color contentBackgroundColor;
  final Widget? topContent; // Contenido grande que se desplaza justo debajo de la AppBar

  const CustomScrollScreen({
    super.key,
    required this.title,
    this.drawer,
    this.actions = const [],
    required this.bodyContent,
    this.headerColor = const Color(0xFF84B9BF), // Color por defecto
    this.contentBackgroundColor = const Color(0xFFE1EDE9), // Color por defecto del cuerpo
    this.topContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar Fijo (Iconos)
          SliverAppBar(
            backgroundColor: headerColor,
            pinned: true,
            floating: false,
            // La altura es 0 para que solo muestre la barra estándar del AppBar
            expandedHeight: 0.0, 
            elevation: 0,
            
            // Icono de menú (Solo si hay drawer)
            leading: drawer != null ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ) : null,
            
            // Iconos de acciones (Notificaciones, etc.)
            actions: actions,
            
            // Título vacío para asegurar que solo se muestren los iconos
            title: Container(), 
          ),

          // 2. Contenido Superior Desplazable (Título, subtítulo, botones, etc.)
          if (topContent != null)
            SliverToBoxAdapter(
              child: Container(
                color: headerColor, // Mantiene la continuidad del color fijo
                child: topContent,
              ),
            ),

          // 3. El resto del contenido de la pantalla (Calendario, Tareas, etc.)
          SliverToBoxAdapter(
            child: Container(
              // Usamos el color de fondo para el cuerpo, que es donde se verá el contenido.
              color: contentBackgroundColor,
              
              // Si NO hay topContent, iniciamos un gradiente desde el headerColor
              // para hacer la transición visualmente suave (mantiene el estilo visual original).
              decoration: topContent == null 
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [headerColor, contentBackgroundColor],
                        stops: const [0.0, 0.1], // Transición corta
                      ),
                    )
                  : null, 
              
              child: bodyContent,
            ),
          ),
        ],
      ),
    );
  }
}