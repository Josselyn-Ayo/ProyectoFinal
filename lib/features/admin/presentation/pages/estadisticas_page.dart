import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/theme.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';

class AdminEstadisticasPage extends StatefulWidget {
  const AdminEstadisticasPage({super.key});

  @override
  State<AdminEstadisticasPage> createState() => _AdminEstadisticasPageState();
}

class _AdminEstadisticasPageState extends State<AdminEstadisticasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteProvider>().cargarTodosIncidentes();
    });
  }

  List<FlSpot> _lineChartData() {
    final spots = <FlSpot>[];
    for (int i = 11; i >= 0; i--) {
      spots.add(FlSpot((11 - i).toDouble(), (i * 3 + 5).toDouble()));
    }
    return spots;
  }

  List<PieChartSectionData> _pieChartData(Map<String, int> tipos) {
    if (tipos.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'Sin datos',
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
          radius: 60,
        )
      ];
    }

    final colors = [
      AppTheme.dangerColor,
      AppTheme.primaryColor,
      AppTheme.warningColor,
      AppTheme.successColor,
      AppTheme.secondaryColor,
    ];

    int idx = 0;
    return tipos.entries.map((e) {
      final color = colors[idx % colors.length];
      idx++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${e.key}\n(${e.value})',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
        radius: 60,
      );
    }).toList();
  }

  List<BarChartGroupData> _barChartData() {
    return List.generate(6, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (i * 2 + 3).toDouble(),
            color: AppTheme.primaryColor,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    if (incidenteProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tipos = incidenteProvider.getIncidentesPorTipo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiempo Promedio de Respuesta',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('~12 min',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Incidentes por Mes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) =>
                              Text('${value.toInt()}',
                                  style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final months = [
                              'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                              'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
                            ];
                            final monthIdx =
                                (DateTime.now().month - 6 + value.toInt())
                                        .clamp(0, 11);
                            return Text(
                                months[monthIdx % 12],
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _lineChartData(),
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        isCurved: true,
                        dotData:
                            FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tipos de Emergencias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: _pieChartData(tipos),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Incidentes por Edificio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) =>
                              Text('${value.toInt()}',
                                  style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final labels = [
                              'A', 'B', 'C', 'D', 'E', 'F'
                            ];
                            return Text(
                                labels[value.toInt() % labels.length],
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _barChartData(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
