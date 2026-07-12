import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/widgets/campus_map_widget.dart';
import '../../../edificio/domain/entities/edificio.dart';
import '../../../edificio/presentation/providers/edificio_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import '../../../incidente/domain/entities/incidente.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';

class MapaSeguridadPage extends StatefulWidget {
  const MapaSeguridadPage({super.key});

  @override
  State<MapaSeguridadPage> createState() => _MapaSeguridadPageState();
}

class _MapaSeguridadPageState extends State<MapaSeguridadPage> {
  Timer? _refreshTimer;
  IncidenteEntity? _selectedIncidente;
  EdificioEntity? _selectedEdificio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
    final activos = incidenteProvider.incidentesActivos
        .where((incidente) => incidente.latitud != null && incidente.longitud != null)
        .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CampusMapWidget(
              incidentes: activos,
              edificios: edificioProvider.edificios,
              onIncidenteTap: (incidente) {
                setState(() {
                  _selectedEdificio = null;
                  _selectedIncidente = incidente;
                });
              },
              onEdificioTap: (edificio) {
                setState(() {
                  _selectedIncidente = null;
                  _selectedEdificio = edificio;
                });
              },
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                _LegendDot(color: AppTheme.dangerColor, label: 'Incidentes'),
                const SizedBox(width: 16),
                _LegendDot(color: AppTheme.successColor, label: 'Edificios'),
                const Spacer(),
                Text(
                  '${activos.length} activos',
                  style: TextStyle(
                    color: AppTheme.dangerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recargar',
                ),
              ],
            ),
          ),
        ),
        if (_selectedIncidente != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildIncidenteCard(_selectedIncidente!),
          ),
        if (_selectedEdificio != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildEdificioCard(_selectedEdificio!),
          ),
        if (activos.isEmpty && !incidenteProvider.loading)
          const Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay incidentes activos con ubicacion para mostrar en el mapa.',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIncidenteCard(IncidenteEntity incidente) {
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
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedIncidente = null),
                ),
              ],
            ),
            if (incidente.descripcion != null && incidente.descripcion!.trim().isNotEmpty)
              Text(
                incidente.descripcion!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            const SizedBox(height: 4),
            Text(
              incidente.anonimo
                  ? 'Anonimo'
                  : incidente.usuarioNombre ?? 'Usuario sin nombre',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final guardiaProvider = context.read<GuardiaProvider>();
                  final miGuardia = guardiaProvider.miGuardia;
                  final ok = await context
                      .read<IncidenteProvider>()
                      .actualizarEstado(
                        incidente.id,
                        'Guardia asignado',
                        guardiaId: miGuardia?.id,
                      );
                  if (ok && miGuardia?.id != null) {
                    await guardiaProvider.actualizarEstado(
                      guardiaId: miGuardia!.id!,
                      estado: 'Ocupado',
                    );
                  }
                  if (ok && mounted) {
                    setState(() => _selectedIncidente = null);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Aceptar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdificioCard(EdificioEntity edificio) {
    return Card(
      child: ListTile(
        title: Text(
          edificio.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          edificio.descripcion?.trim().isNotEmpty == true
              ? edificio.descripcion!
              : 'Punto del campus registrado en el mapa.',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _selectedEdificio = null),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
