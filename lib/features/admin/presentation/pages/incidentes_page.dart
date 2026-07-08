import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme.dart';
import '../../../incidente/domain/entities/incidente.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';

class AdminIncidentesPage extends StatefulWidget {
  const AdminIncidentesPage({super.key});

  @override
  State<AdminIncidentesPage> createState() => _AdminIncidentesPageState();
}

class _AdminIncidentesPageState extends State<AdminIncidentesPage> {
  String _filter = 'Todos';
  final _searchCtrl = TextEditingController();
  final Set<int> _expandedIndexes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteProvider>().cargarTodosIncidentes();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<IncidenteEntity> _filterIncidentes(List<IncidenteEntity> lista) {
    var filtered = _filter == 'Todos'
        ? lista
        : lista.where((i) {
            switch (_filter) {
              case 'Reportado':
                return i.estado == 'Reportado';
              case 'En proceso':
                return ['Guardia asignado', 'En camino'].contains(i.estado);
              case 'Atendido':
                return i.estado == 'Atendido';
              case 'Cerrado':
                return i.estado == 'Cerrado';
              default:
                return true;
            }
          }).toList();

    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((i) =>
              i.tipo.toLowerCase().contains(query) ||
              (i.usuarioNombre ?? '').toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Reportado':
        return AppTheme.dangerColor;
      case 'Guardia asignado':
        return AppTheme.primaryColor;
      case 'En camino':
        return AppTheme.warningColor;
      case 'Atendido':
        return AppTheme.successColor;
      case 'Cerrado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _prioridadColor(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return AppTheme.dangerColor;
      case 'Media':
        return AppTheme.warningColor;
      case 'Baja':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void _showDeleteDialog(IncidenteEntity incidente) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar Incidente'),
          content: Text('¿Eliminar el incidente "${incidente.tipo}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                context
                    .read<IncidenteProvider>()
                    .eliminarIncidente(incidente.id);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerColor),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    if (incidenteProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filterIncidentes(incidenteProvider.todosIncidentes);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar incidentes...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Todos', 'Reportado', 'En proceso', 'Atendido', 'Cerrado'
              ].map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
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
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No se encontraron incidentes',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final inc = filtered[i];
                    final isExpanded = _expandedIndexes.contains(i);
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
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
                                Text(inc.usuarioNombre ?? 'Usuario'),
                                Text(_formatDate(inc.fecha)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(inc.estado,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  backgroundColor: _estadoColor(inc.estado),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedIndexes.remove(i);
                                } else {
                                  _expandedIndexes.add(i);
                                }
                              });
                            },
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  if (inc.descripcion != null) ...[
                                    const Text('Descripción:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(inc.descripcion!),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    children: [
                                      const Text('Prioridad: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      PopupMenuButton<String>(
                                        initialValue: inc.prioridad ?? 'Media',
                                        child: Chip(
                                          label: Text(inc.prioridad ?? 'Media',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11)),
                                          backgroundColor:
                                              _prioridadColor(
                                                  inc.prioridad ?? 'Media'),
                                        ),
                                        onSelected: (v) {
                                          context
                                              .read<IncidenteProvider>()
                                              .actualizarPrioridad(
                                                  inc.id, v);
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                              value: 'Alta',
                                              child: Text('Alta')),
                                          const PopupMenuItem(
                                              value: 'Media',
                                              child: Text('Media')),
                                          const PopupMenuItem(
                                              value: 'Baja',
                                              child: Text('Baja')),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          if (inc.latitud != null)
                                            Text(
                                                '📍 ${inc.latitud!.toStringAsFixed(4)}, ${inc.longitud!.toStringAsFixed(4)}',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: AppTheme.dangerColor),
                                        onPressed: () =>
                                            _showDeleteDialog(inc),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
