import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/widgets/campus_map_widget.dart';
import '../../../edificio/presentation/providers/edificio_provider.dart';
import '../providers/incidente_provider.dart';
import '../../domain/entities/incidente.dart';

class MapaIncidentePage extends StatefulWidget {
  const MapaIncidentePage({super.key});

  @override
  State<MapaIncidentePage> createState() => _MapaIncidentePageState();
}

class _MapaIncidentePageState extends State<MapaIncidentePage> {
  IncidenteEntity? _selectedIncidente;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<IncidenteProvider>().cargarIncidentesActivos(),
      context.read<EdificioProvider>().cargarEdificios(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();
    final edificioProvider = context.watch<EdificioProvider>();
    final incidentesConUbicacion = incidenteProvider.incidentesActivos
        .where((incidente) => incidente.latitud != null && incidente.longitud != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del campus'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: incidenteProvider.loading && incidenteProvider.incidentesActivos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        CampusMapWidget(
                          incidentes: incidentesConUbicacion,
                          edificios: edificioProvider.edificios,
                          onIncidenteTap: (incidente) {
                            setState(() => _selectedIncidente = incidente);
                          },
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: _MapSummaryBar(
                            incidentesActivos: incidentesConUbicacion.length,
                            edificios: edificioProvider.edificios.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedIncidente != null)
                    _IncidenteInfoCard(
                      incidente: _selectedIncidente!,
                      onClose: () => setState(() => _selectedIncidente = null),
                    )
                  else
                    const _MapHintCard(),
                ],
              ),
            ),
    );
  }
}

class _MapSummaryBar extends StatelessWidget {
  final int incidentesActivos;
  final int edificios;

  const _MapSummaryBar({
    required this.incidentesActivos,
    required this.edificios,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor),
          const SizedBox(width: 8),
          Text('$incidentesActivos incidentes'),
          const SizedBox(width: 16),
          const Icon(Icons.business, color: AppTheme.successColor),
          const SizedBox(width: 8),
          Text('$edificios edificios'),
        ],
      ),
    );
  }
}

class _MapHintCard extends StatelessWidget {
  const _MapHintCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.touch_app, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Toca un marcador rojo para ver el detalle del incidente.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidenteInfoCard extends StatelessWidget {
  final IncidenteEntity incidente;
  final VoidCallback onClose;

  const _IncidenteInfoCard({
    required this.incidente,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    incidente.tipo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (incidente.descripcion != null && incidente.descripcion!.trim().isNotEmpty)
              Text(incidente.descripcion!),
            const SizedBox(height: 8),
            Text(
              'Estado: ${incidente.estadoFormateado}',
              style: TextStyle(
                color: incidente.estado.toLowerCase() == 'cerrado'
                    ? Colors.grey
                    : AppTheme.dangerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (incidente.usuarioNombre != null && incidente.usuarioNombre!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Reportado por: ${incidente.usuarioNombre!}'),
              ),
          ],
        ),
      ),
    );
  }
}
