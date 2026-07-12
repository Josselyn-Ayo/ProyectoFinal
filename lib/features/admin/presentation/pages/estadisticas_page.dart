import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../incidente/domain/entities/incidente.dart';
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

  List<FlSpot> _lineChartData(List<IncidenteEntity> incidentes) {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int offset = 5; offset >= 0; offset--) {
      final targetMonth = DateTime(now.year, now.month - offset, 1);
      final total = incidentes.where((incidente) {
        final fecha = incidente.fecha;
        return fecha != null &&
            fecha.year == targetMonth.year &&
            fecha.month == targetMonth.month;
      }).length;
      spots.add(FlSpot((5 - offset).toDouble(), total.toDouble()));
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
        ),
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
    return tipos.entries.map((entry) {
      final color = colors[idx % colors.length];
      idx++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n(${entry.value})',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
        radius: 60,
      );
    }).toList();
  }

  List<BarChartGroupData> _barChartData(List<IncidenteEntity> incidentes) {
    final prioridades = ['Alta', 'Media', 'Baja'];

    return List.generate(prioridades.length, (index) {
      final prioridad = prioridades[index];
      final total = incidentes
          .where((incidente) => (incidente.prioridad ?? 'Media') == prioridad)
          .length;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total.toDouble(),
            color: AppTheme.primaryColor,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  double _resolvedRate(List<IncidenteEntity> incidentes) {
    final cerrados = incidentes.where((incidente) {
      return incidente.fecha != null && incidente.estado.toLowerCase() == 'cerrado';
    }).length;

    if (incidentes.isEmpty) return 0;
    return (cerrados / incidentes.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    if (incidenteProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final incidentes = incidenteProvider.todosIncidentes;
    final tipos = incidenteProvider.getIncidentesPorTipo();
    final lineData = _lineChartData(incidentes);
    final barData = _barChartData(incidentes);
    final resueltos = _resolvedRate(incidentes);

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
                      const Text(
                        'Casos resueltos',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incidentes.isEmpty ? 'Sin datos' : '${resueltos.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Incidentes por mes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final now = DateTime.now();
                            final targetMonth = DateTime(now.year, now.month - (5 - value.toInt()), 1);
                            const months = [
                              'Ene',
                              'Feb',
                              'Mar',
                              'Abr',
                              'May',
                              'Jun',
                              'Jul',
                              'Ago',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dic',
                            ];
                            return Text(
                              months[targetMonth.month - 1],
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: lineData,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        isCurved: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tipos de emergencias',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
          const Text(
            'Incidentes por prioridad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = ['Alta', 'Media', 'Baja'];
                            return Text(
                              labels[value.toInt() % labels.length],
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barData,
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
