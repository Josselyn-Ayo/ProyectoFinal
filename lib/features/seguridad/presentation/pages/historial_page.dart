import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import '../../../incidente/domain/entities/incidente.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  String _filter = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteProvider>().cargarTodosIncidentes();
    });
  }

  List<IncidenteEntity> _filterIncidentes(List<IncidenteEntity> lista) {
    final guardiaProvider = context.read<GuardiaProvider>();
    final miGuardia = guardiaProvider.miGuardia;

    final cerrados = lista
        .where((i) =>
            ['Atendido', 'Cerrado'].contains(i.estado) &&
            i.guardiaId == miGuardia?.id)
        .toList();

    final now = DateTime.now();
    switch (_filter) {
      case 'Hoy':
        return cerrados
            .where((i) =>
                i.fecha != null &&
                i.fecha!.day == now.day &&
                i.fecha!.month == now.month &&
                i.fecha!.year == now.year)
            .toList();
      case 'Semana':
        final weekAgo = now.subtract(const Duration(days: 7));
        return cerrados
            .where((i) => i.fecha != null && i.fecha!.isAfter(weekAgo))
            .toList();
      case 'Mes':
        final monthAgo = now.subtract(const Duration(days: 30));
        return cerrados
            .where((i) => i.fecha != null && i.fecha!.isAfter(monthAgo))
            .toList();
      default:
        return cerrados;
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Atendido':
        return AppTheme.successColor;
      case 'Cerrado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    if (incidenteProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filterIncidentes(incidenteProvider.todosIncidentes);
    final totalAtendidos = filtered.where((i) => i.estado == 'Atendido').length;
    final totalCerrados = filtered.where((i) => i.estado == 'Cerrado').length;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                  label: 'Atendidos',
                  value: totalAtendidos.toString(),
                  color: AppTheme.successColor),
              _StatItem(
                  label: 'Cerrados',
                  value: totalCerrados.toString(),
                  color: Colors.grey),
              _StatItem(
                  label: 'T. Promedio',
                  value: '~45 min',
                  color: AppTheme.primaryColor),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todos', 'Hoy', 'Semana', 'Mes'].map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay incidentes en el historial',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final inc = filtered[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _estadoColor(inc.estado),
                          child: const Icon(Icons.report,
                              color: Colors.white),
                        ),
                        title: Text(inc.tipo,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDate(inc.fecha)),
                            if (inc.usuarioNombre != null)
                              Text(inc.usuarioNombre!,
                                  style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(inc.estado,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                          backgroundColor: _estadoColor(inc.estado),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
