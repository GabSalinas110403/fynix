import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: Container(
        color: const Color(0xFF06373E),
        child: SafeArea(
          child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF06373E)),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.black87),
              ),
            ),
            drawerItem(Icons.home, "Inicio", "/", context),
            drawerItem(Icons.show_chart, "Finanzas", "/finanzas", context),
            drawerItem(Icons.person, "Proveedores", "/proveedores", context),
            drawerItem(Icons.people, "Personal", "/personal", context),
            drawerItem(Icons.insert_drive_file, "Reportes", "/reportes", context),
            drawerItem(Icons.store, "Almacén", "/almacen", context),
            const Spacer(),
            drawerItem(Icons.logout, "Salir", "/", context),
          ],
        ),
        ),
      ),
    );
  }

  Widget drawerItem(
      IconData icon, String title, String route, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
