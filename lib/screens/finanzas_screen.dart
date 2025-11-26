import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para TextInputFormatter
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../widgets/custom_drawer.dart';
import 'package:fynix/helpers/pdf_export_helper.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  static const Color primaryColor = Color(0xFF84B9BF);
  static const Color accentColor = Color(0xFFE1EDE9);
  static const Color textColor = Color(0xFF06373E);

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  // ------------------------------------------------------
  // GUARDAR LOCALMENTE
  // ------------------------------------------------------
  Future<void> _guardarRegistros() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> convertidos = registros.map((e) {
      return "${e['tipo']}|${e['nombre']}|${e['cantidad']}|${(e['fecha'] as DateTime).toIso8601String()}";
    }).toList();

    await prefs.setStringList('registros_finanzas', convertidos);
  }

  // ------------------------------------------------------
  // CARGAR LOCALMENTE
  // ------------------------------------------------------
  Future<void> _cargarRegistros() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('registros_finanzas');

    if (data == null) return;

    List<Map<String, dynamic>> temp = data.map((e) {
      final partes = e.split("|");
      return {
        "tipo": partes[0],
        "nombre": partes[1],
        "cantidad": double.parse(partes[2]),
        "fecha": DateTime.parse(partes[3]),
      };
    }).toList();

    setState(() => registros = temp);
  }

  // ------------------------------------------------------
  // MODAL PARA AGREGAR INGRESO/GASTO (CON VALIDACIÓN)
  // ------------------------------------------------------
  void _abrirModal(bool esIngreso) {
    final _formKey = GlobalKey<FormState>();
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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(
                    labelText:
                        esIngreso ? "Nombre del ingreso" : "Nombre del gasto",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo no puede estar vacío';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cantidadCtrl,
                  decoration: const InputDecoration(labelText: "Cantidad (MXN)"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  // Permite ingresar solo números y un punto decimal
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese una cantidad';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Cantidad inválida (solo números)';
                    }
                    if (amount <= 0) {
                      return 'La cantidad debe ser mayor que cero';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validación del formulario
                if (_formKey.currentState!.validate()) {
                  String nombre = nombreCtrl.text.trim();
                  double cantidad = double.parse(cantidadCtrl.text);

                  setState(() {
                    registros.add({
                      "tipo": esIngreso ? "ingreso" : "gasto",
                      "nombre": nombre,
                      "cantidad": cantidad,
                      "fecha": DateTime.now(),
                    });
                    registros.sort((a, b) => b["fecha"].compareTo(a["fecha"]));
                  });

                  await _guardarRegistros();

                  Navigator.pop(context);
                  // Opcional: Mostrar SnackBar de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(esIngreso
                            ? 'Ingreso guardado'
                            : 'Gasto guardado')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FinanzasScreen.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------
  // GENERAR SPOTS PARA LA GRÁFICA
  // ------------------------------------------------------
  List<FlSpot> _generarSpots() {
    if (registros.isEmpty) return const [FlSpot(0, 0)];

    final sorted = List<Map<String, dynamic>>.from(registros)
      ..sort((a, b) => a["fecha"].compareTo(b["fecha"]));

    double balance = 0;
    List<FlSpot> spots = [];

    spots.add(const FlSpot(0, 0));

    for (int i = 0; i < sorted.length; i++) {
      final e = sorted[i];
      double valor = e["cantidad"] * (e["tipo"] == "ingreso" ? 1 : -1);
      balance += valor;
      spots.add(FlSpot(i.toDouble() + 1, balance));
    }

    return spots;
  }

  // ------------------------------------------------------
  // TOTALES
  // ------------------------------------------------------
  double get totalIngresos => registros
      .where((e) => e["tipo"] == "ingreso")
      .fold(0.0, (s, e) => s + e["cantidad"]);

  double get totalGastos => registros
      .where((e) => e["tipo"] == "gasto")
      .fold(0.0, (s, e) => s + e["cantidad"]);

  double get totalRestante => totalIngresos - totalGastos;

Future<void> generarPDF() async {
  await PDFExportHelper.exportToPDF<Map<String, dynamic>>(
    context: context,
    data: registros,
    title: 'Reporte de Finanzas',
    fileName: 'Reporte_Finanzas',
    buildContent: (registros) {
      // Ordenar por fecha descendente
      final sortedRegistros = List<Map<String, dynamic>>.from(registros)
        ..sort((a, b) => b["fecha"].compareTo(a["fecha"]));

      return [
        // Resumen General
        pw.Text(
          'Resumen General',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(thickness: 1, color: PdfColor.fromHex('#84B9BF')),
        pw.SizedBox(height: 10),
        
        // Fila de Ingresos
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Ingresos Totales:',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                '\$${totalIngresos.toStringAsFixed(2)} MXN',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                ),
              ),
            ],
          ),
        ),
        
        // Fila de Gastos
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Gastos Totales:',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                '\$${totalGastos.toStringAsFixed(2)} MXN',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red,
                ),
              ),
            ],
          ),
        ),
        
        // Fila de Balance
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Balance Final:',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                '\$${totalRestante.toStringAsFixed(2)} MXN',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
            ],
          ),
        ),
        
        pw.SizedBox(height: 20),
        
        // Detalle de Movimientos
        pw.Text(
          'Detalle de Movimientos',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(thickness: 1, color: PdfColor.fromHex('#84B9BF')),
        pw.SizedBox(height: 10),
        
        // Tabla de movimientos
        PDFExportHelper.buildTable(
          headers: ['Tipo', 'Descripción', 'Cantidad (MXN)', 'Fecha'],
          data: sortedRegistros.map((e) {
            final isIngreso = e['tipo'] == 'ingreso';
            return [
              isIngreso ? 'INGRESO' : 'GASTO',
              e['nombre'].toString(),
              '${isIngreso ? '+' : '-'} \$${e['cantidad'].toStringAsFixed(2)}',
              DateFormat('dd/MM/yyyy HH:mm').format(e['fecha']),
            ];
          }).toList(),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF84B9BF),
          ),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        ),
      ];
    },
  );
}
  pw.Widget _buildPdfTable() {
    final tableHeaders = ['Tipo', 'Descripción', 'Cantidad (MXN)', 'Fecha'];

    final sortedRegistros = List<Map<String, dynamic>>.from(registros)
      ..sort((a, b) => b["fecha"].compareTo(a["fecha"]));

    return pw.Table.fromTextArray(
      headers: tableHeaders,
      data: sortedRegistros.map((e) {
        final isIngreso = e['tipo'] == 'ingreso';
        return [
          isIngreso ? 'INGRESO' : 'GASTO',
          e['nombre'].toString(),
          '${isIngreso ? '+' : '-'} \$${e['cantidad'].toStringAsFixed(2)}',
          DateFormat('dd/MM/yyyy HH:mm').format(e['fecha']),
        ];
      }).toList(),
      border: pw.TableBorder.all(color: PdfColor.fromHex('#84B9BF')),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColor.fromInt(0xFF84B9BF)),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  pw.Widget _buildPdfRow(String label, double amount, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            '\$${amount.toStringAsFixed(2)} MXN',
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // UI
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Container(
              color: FinanzasScreen.accentColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildResumen(),
                  const SizedBox(height: 10),

                  // -------------------------------
                  // BOTÓN DE EXPORTAR PDF (OPCIÓN B)
                  // -------------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: generarPDF,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text(
                        "Exportar PDF",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FinanzasScreen.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildListaRegistros(),
                  const SizedBox(height: 20),
                  _buildGrafica(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // COMPONENTES DE UI
  // ----------------------------------------------------------------

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 220.0,
      backgroundColor: FinanzasScreen.primaryColor,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(),
        background: Container(
          color: FinanzasScreen.primaryColor,
          padding: const EdgeInsets.only(top: 80, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Finanzas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Registro y gestión',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton('Nuevo Ingreso', true, Colors.green),
                  const SizedBox(width: 15),
                  _buildActionButton('Nuevo Gasto', false, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, bool isIncome, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _abrirModal(isIncome),
      icon: Icon(isIncome ? Icons.add : Icons.remove, color: color),
      label: Text(
        text,
        style: TextStyle(
          color: FinanzasScreen.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      // AJUSTE DE POSICIÓN: Valor reducido de -28.0 a -16.0
      transform: Matrix4.translationValues(0.0, 10.0, 0.0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FinanzasScreen.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ingresos Totales',
                  style: TextStyle(
                      color: FinanzasScreen.textColor, fontSize: 16)),
              const Text('Total Restante',
                  style: TextStyle(
                      color: FinanzasScreen.textColor, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${totalIngresos.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${totalRestante.toStringAsFixed(2)} MXN',
                style: TextStyle(
                  color: totalRestante >= 0 ? Colors.blue : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text('Gastos Totales',
              style: TextStyle(
                  color: FinanzasScreen.textColor, fontSize: 16)),
          Text(
            '\$${totalGastos.toStringAsFixed(2)} MXN',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaRegistros() {
    if (registros.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          // AJUSTE DE POSICIÓN: Valor reducido de -28.0 a -16.0
          transform: Matrix4.translationValues(0.0, -16.0, 0.0),
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay registros financieros.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Map<String, List<Map<String, dynamic>>> gruposFecha = {};
    for (var e in registros) {
      String key = DateFormat('dd MMM yyyy', 'es').format(e['fecha']);
      if (!gruposFecha.containsKey(key)) {
        gruposFecha[key] = [];
      }
      gruposFecha[key]!.add(e);
    }

    return Container(
      // AJUSTE DE POSICIÓN: Valor reducido de -28.0 a -16.0
      transform: Matrix4.translationValues(0.0, 6.0, 0.0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: gruposFecha.entries.map((grupo) {
          grupo.value.sort((a, b) => b["fecha"].compareTo(a["fecha"]));

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grupo.key,
                  style: const TextStyle(
                      color: FinanzasScreen.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: FinanzasScreen.primaryColor.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: grupo.value.map((e) {
                      final isIngreso = e["tipo"] == "ingreso";
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: _buildItem(
                          e["nombre"],
                          (isIngreso ? "+ " : "- ") +
                              "\$${e["cantidad"].toStringAsFixed(2)}",
                          isIngreso
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          isIngreso
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrafica() {
    return Container(
      // AJUSTE DE POSICIÓN: Valor reducido de -28.0 a -16.0
      transform: Matrix4.translationValues(0.0, -16.0, 0.0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FinanzasScreen.primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 220,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _generarSpots(),
              isCurved: true,
              color: FinanzasScreen.primaryColor,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: FinanzasScreen.primaryColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      String nombre, String monto, Color color, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on,
                  size: 20, color: textColor.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                nombre,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            monto,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
