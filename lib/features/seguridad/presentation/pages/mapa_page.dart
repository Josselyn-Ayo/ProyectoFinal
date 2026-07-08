import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../edificio/presentation/providers/edificio_provider.dart';
import '../../../incidente/domain/entities/incidente.dart';

class MapaSeguridadPage extends StatefulWidget {
  const MapaSeguridadPage({super.key});

  @override
  State<MapaSeguridadPage> createState() => _MapaSeguridadPageState();
}

class _MapaSeguridadPageState extends State<MapaSeguridadPage> {
  Timer? _refreshTimer;
  IncidenteEntity? _selectedIncidente;

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

  void _loadData() {
    context.read<IncidenteProvider>().cargarTodosIncidentes();
    context.read<EdificioProvider>().cargarEdificios();
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();
    final activos = incidenteProvider.incidentesActivos;

    return Stack(
      children: [
        Container(
          color: Colors.grey[300],
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, size: 80, color: Colors.grey),
                SizedBox(height: 12),
                Text('Mapa de seguridad',
                    style: TextStyle(color: Colors.grey, fontSize: 18)),
                SizedBox(height: 4),
                Text('${0} incidentes activos en el mapa',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
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
                Text('${activos.length} activos',
                    style: TextStyle(
                        color: AppTheme.dangerColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        if (_selectedIncidente != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildInfoCard(_selectedIncidente!),
          ),
      ],
    );
  }

  Widget _buildInfoCard(IncidenteEntity incidente) {
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
                  child: Text(incidente.tipo,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      setState(() => _selectedIncidente = null),
                ),
              ],
            ),
            if (incidente.descripcion != null)
              Text(incidente.descripcion!,
                  style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(incidente.usuarioNombre ?? '',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<IncidenteProvider>()
                      .actualizarEstado(incidente.id, 'Guardia asignado');
                  setState(() => _selectedIncidente = null);
                },
                icon: const Icon(Icons.check),
                label: const Text('Aceptar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor),
              ),
            ),
          ],
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
