import 'package:flutter/material.dart';
import 'package:fynix/widgets/custom_drawer.dart'; 

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  static const Color headerColor = Color(0xFF84B9BF);
  static const Color listBackgroundColor = Color(0xFFE0F2F1); 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        
        slivers: [
          SliverAppBar(
            backgroundColor: headerColor,
            pinned: true, 
            floating: false,
            snap: false, 
            expandedHeight: 220.0,
            elevation: 0, 
            
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 30),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NO SIRVE AAAUN')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ], 
            
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(), 
              background: Container(
                color: headerColor,
                padding: const EdgeInsets.only(top: 80, bottom: 20, left: 16, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Reportes",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Generación y Análisis",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generando reporte NO SIRVE AUN...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: headerColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Generar reporte",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              color: listBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchAndFilterBar(),
                  SizedBox(height: 25),
                  CashFlowSummaryCard(), 
                  SizedBox(height: 25), 
                  ReportsList(), 
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0.0, 18.0, 0.0),
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
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Buscar . . .",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: ReportesScreen.headerColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_list, color: ReportesScreen.headerColor, size: 30),
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

class CashFlowSummaryCard extends StatelessWidget {
  const CashFlowSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Flujo de Caja",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 12),
            _ReportDetailsWithGraph(),
          ],
        ),
      ),
    );
  }
}


class ReportsList extends StatelessWidget {
  const ReportsList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: Text(
            "Reportes Generados",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),

        // Reportes individuales
        ReportCard(
          date: "10 ago 2025",
          title: "Análisis de Datos",
          extraInfo: "Id: 108752",
          detailsWidget: _SimpleReportDetails(
            details: ["Definición del reporte: lorem ipsum dolor sit amet, consectetur adipiscing elit. /n lorem ipsum dolor sit amet, consectetur adipiscing elit. "],
          ),
        ),
        SizedBox(height: 15),
        
        ReportCard(
          date: "22 jul 2025",     
          title: "Informe Financiero",
          extraInfo: "Id: 227634",
          detailsWidget: _SimpleReportDetails(
            details: ["Definición del reporte: lorem ipsum dolor sit amet, consectetur adipiscing elit. /n lorem ipsum dolor sit amet, consectetur adipiscing elit. "],
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}


class _SimpleReportDetails extends StatelessWidget {
  final List<String> details;
  const _SimpleReportDetails({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) => Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          detail,
          style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
        ),
      )).toList(),
    );
  }
}

class _ReportDetailsWithGraph extends StatelessWidget {
  const _ReportDetailsWithGraph();

  @override
  Widget build(BuildContext context) {
    const Color greenText = Color(0xFF1976D2); 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Ingresos Totales", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                SizedBox(height: 4),
                Text("\$ 15,000 MXN", style: TextStyle(fontSize: 16, color: ReportesScreen.headerColor, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Total Restante", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("+ \$ 7,650 MXN", style: TextStyle(fontSize: 16, color: greenText, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Gastos Totales", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            SizedBox(height: 4),
            Text("\$ 7,350 MXN", style: TextStyle(fontSize: 16, color: ReportesScreen.headerColor, fontWeight: FontWeight.bold)),
          ],
        ),
        
        const SizedBox(height: 20),
        
         Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ReportesScreen.listBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              "Espacio para la Gráfica de Flujo (Ingresos vs Gastos)",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ),

        const SizedBox(height: 15),
        
//Para la parte de exportación
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botón EXCEL
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReportesScreen.headerColor.withOpacity(0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("EXCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            // Botón PDF
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReportesScreen.headerColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class ReportCard extends StatelessWidget {
  final String date;
  final String title;
  final String extraInfo;
  final Widget detailsWidget; 

  const ReportCard({
    super.key,
    required this.date,
    required this.title,
    required this.extraInfo,
    required this.detailsWidget, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  extraInfo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ReportesScreen.headerColor),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12), 

            detailsWidget,
          ],
        ),
      ),
    );
  }
}