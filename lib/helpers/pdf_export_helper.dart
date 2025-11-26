import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

/// Clase helper para exportar datos a PDF de manera genérica
class PDFExportHelper {
  /// Método principal para exportar a PDF
  /// 
  /// [context] - Contexto de Flutter para mostrar SnackBars
  /// [data] - Lista de datos a exportar
  /// [title] - Título del reporte
  /// [fileName] - Nombre base del archivo
  /// [buildContent] - Función que construye el contenido del PDF
  /// [filters] - Mapa opcional de filtros aplicados
  static Future<void> exportToPDF<T>({
    required BuildContext context,
    required List<T> data,
    required String title,
    required String fileName,
    required List<pw.Widget> Function(List<T>) buildContent,
    Map<String, dynamic>? filters,
  }) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay resultados para exportar')),
      );
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return [
              // Encabezado genérico
              _buildHeader(title, data.length, filters),
              pw.SizedBox(height: 20),
              // Contenido personalizado
              ...buildContent(data),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final bytes = Uint8List.fromList(pdfBytes);

      // Siempre usar el método de compartir/descargar directo
      await _shareOrDownloadPdf(context, bytes, fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  /// Construye el encabezado del PDF
  static pw.Widget _buildHeader(
    String title,
    int resultCount,
    Map<String, dynamic>? filters,
  ) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#84B9BF'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Fecha de generación: ${_formatDate(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          if (filters != null && filters.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Filtros aplicados:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            ...filters.entries.map((entry) {
              return pw.Text(
                '• ${entry.key}: ${entry.value}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              );
            }).toList(),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            'Total de resultados: $resultCount',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(thickness: 2, color: PdfColor.fromHex('#84B9BF')),
        ],
      ),
    );
  }

  /// Formatea una fecha
  static String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Comparte o descarga el PDF directamente
  static Future<void> _shareOrDownloadPdf(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final timestamp = DateTime.now();
      final fullFileName = '${fileName}_${timestamp.day}-${timestamp.month}-${timestamp.year}_${timestamp.hour}-${timestamp.minute}.pdf';
      
      // Usar Printing.sharePdf que abre el diálogo de compartir nativo
      await Printing.sharePdf(
        bytes: bytes, 
        filename: fullFileName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generado exitosamente'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Helper para crear tablas en PDF
  static pw.Widget buildTable({
    required List<String> headers,
    required List<List<String>> data,
    pw.TableBorder? border,
    pw.BoxDecoration? headerDecoration,
    pw.BoxDecoration? oddRowDecoration,
  }) {
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: border ?? pw.TableBorder.all(color: PdfColor.fromHex('#84B9BF')),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: headerDecoration ?? 
        const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      oddRowDecoration: oddRowDecoration,
    );
  }
}