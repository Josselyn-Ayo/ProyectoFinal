import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import '../../../incidente/domain/entities/incidente.dart';
import 'atender_caso_page.dart';
import 'chat_page.dart';

class EmergenciasPage extends StatefulWidget {
  const EmergenciasPage({super.key});

  @override
  State<EmergenciasPage> createState() => _EmergenciasPageState();
}

class _EmergenciasPageState extends State<EmergenciasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteProvider>().cargarTodosIncidentes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void _showActionSheet(IncidenteEntity incidente) {
    final guardiaProvider = context.read<GuardiaProvider>();
    final incidenteProvider = context.read<IncidenteProvider>();
    final miGuardia = guardiaProvider.miGuardia;
    final esMiCaso = incidente.guardiaId == miGuardia?.id;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  incidente.tipo,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(incidente.usuarioNombre ?? 'Usuario',
                    style: const TextStyle(fontSize: 16)),
                if (incidente.descripcion != null) ...[
                  const SizedBox(height: 4),
                  Text(incidente.descripcion!,
                      style: TextStyle(color: Colors.grey[600])),
                ],
                const SizedBox(height: 16),
                if (incidente.estado == 'Reportado')
                  ElevatedButton.icon(
                    onPressed: () {
                      incidenteProvider.actualizarEstado(
                          incidente.id, 'Guardia asignado');
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Aceptar Caso'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor),
                  ),
                if (incidente.estado == 'Guardia asignado' && esMiCaso)
                  ElevatedButton.icon(
                    onPressed: () {
                      incidenteProvider.actualizarEstado(
                          incidente.id, 'En camino');
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('En camino'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningColor),
                  ),
                if (incidente.estado == 'En camino' && esMiCaso)
                  ElevatedButton.icon(
                    onPressed: () {
                      incidenteProvider.actualizarEstado(
                          incidente.id, 'Atendido');
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Atendido'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor),
                  ),
                if (incidente.estado == 'Atendido' && esMiCaso)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showCerrarCasoDialog(incidente);
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('Cerrar caso'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700]),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AtenderCasoPage(incidente: incidente),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver detalle'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatPage(incidenteId: incidente.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCerrarCasoDialog(IncidenteEntity incidente) {
    final respuestaCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cerrar caso'),
          content: TextField(
            controller: respuestaCtrl,
            decoration: const InputDecoration(
              labelText: 'Respuesta / Resumen',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<IncidenteProvider>()
                    .actualizarEstado(incidente.id, 'Cerrado');
                Navigator.pop(ctx);
              },
              child: const Text('Cerrar caso'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncidenteCard(IncidenteEntity incidente) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _estadoColor(incidente.estado),
          child: const Icon(Icons.report, color: Colors.white),
        ),
        title: Text(incidente.tipo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (incidente.usuarioNombre != null)
              Text(incidente.usuarioNombre!),
            Text(_formatDate(incidente.fecha)),
          ],
        ),
        trailing: Chip(
          label: Text(incidente.estado,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: _estadoColor(incidente.estado),
          padding: EdgeInsets.zero,
        ),
        onTap: () => _showActionSheet(incidente),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    if (incidenteProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activas = incidenteProvider.todosIncidentes
        .where((i) =>
            ['Reportado', 'Guardia asignado', 'En camino'].contains(i.estado))
        .toList();
    final historial = incidenteProvider.todosIncidentes
        .where((i) => ['Atendido', 'Cerrado'].contains(i.estado))
        .toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Activas (${activas.length})'),
              Tab(text: 'Historial (${historial.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(activas),
              _buildList(historial),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<IncidenteEntity> list) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay incidentes',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildIncidenteCard(list[i]),
    );
  }
}
