import 'package:flutter/material.dart';
import 'package:fynix/screens/almacen_screen.dart';
import 'package:fynix/screens/finanzas_screen.dart';
import 'package:fynix/screens/home_screen.dart';
import 'package:fynix/screens/personal_screen.dart';
import 'package:fynix/screens/proveedores_screen.dart';

import 'package:intl/date_symbol_data_local.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fynix App',
      initialRoute: 'home',
       routes: {
        '/': (context) => const HomeScreen(),
        '/finanzas': (context) => const FinanzasScreen(),
        '/proveedores': (context) => const ProveedoresScreen(),
        '/personal': (context) => const PersonalScreen(),
        '/almacen': (context) => const AlmacenScreen(),
      },
    );
  }
}
