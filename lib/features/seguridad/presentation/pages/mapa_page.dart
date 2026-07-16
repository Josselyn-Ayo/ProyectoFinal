import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/services/routing_service.dart';
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
  CampusMapMode _mapMode = CampusMapMode.marcadores;
  List<LatLng> _routePoints = const [];
  LatLng? _guardLocation;
  RouteResult? _routeResult;
  bool _loadingRoute = false;

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

  Future<void> _trazarRuta(IncidenteEntity incidente) async {
    if (incidente.latitud == null || incidente.longitud == null) return;
    setState(() => _loadingRoute = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw StateError('Activa el servicio de ubicacion para trazar la ruta');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
          'Se requiere permiso de ubicacion para obtener la ruta',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final origin = LatLng(position.latitude, position.longitude);
      final route = await RoutingService().obtenerRuta(
        origen: origin,
        destino: LatLng(incidente.latitud!, incidente.longitud!),
      );
      if (!mounted) return;
      setState(() {
        _guardLocation = origin;
        _routePoints = route.points;
        _routeResult = route;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  void _limpiarRuta() {
    setState(() {
      _routePoints = const [];
      _guardLocation = null;
      _routeResult = null;
    });
  }

  String _formatDistance(double meters) {
    return meters >= 1000
        ? '${(meters / 1000).toStringAsFixed(1)} km'
        : '${meters.round()} m';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    return minutes < 60
        ? '$minutes min'
        : '${duration.inHours} h ${minutes.remainder(60)} min';
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();
    final edificioProvider = context.watch<EdificioProvider>();
    final activos = incidenteProvider.incidentesActivos
        .where(
          (incidente) =>
              incidente.latitud != null && incidente.longitud != null,
        )
        .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CampusMapWidget(
              incidentes: activos,
              edificios: edificioProvider.edificios,
              mode: _mapMode,
              routePoints: _routePoints,
              guardLocation: _guardLocation,
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
                _LegendDot(
                  color: _mapMode == CampusMapMode.calor
                      ? const Color(0xFFD32F2F)
                      : AppTheme.dangerColor,
                  label: _mapMode == CampusMapMode.calor
                      ? 'Mayor densidad'
                      : 'Incidentes',
                ),
                const SizedBox(width: 16),
                _LegendDot(color: AppTheme.successColor, label: 'Edificios'),
                const Spacer(),
                PopupMenuButton<CampusMapMode>(
                  tooltip: 'Cambiar visualizacion',
                  icon: Icon(
                    _mapMode == CampusMapMode.calor
                        ? Icons.local_fire_department
                        : Icons.location_on,
                  ),
                  onSelected: (mode) => setState(() => _mapMode = mode),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: CampusMapMode.marcadores,
                      child: Text('Marcadores'),
                    ),
                    PopupMenuItem(
                      value: CampusMapMode.calor,
                      child: Text('Mapa de calor'),
                    ),
                  ],
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
        if (_routeResult != null)
          Positioned(
            bottom: _selectedIncidente == null ? 16 : 190,
            left: 16,
            right: 16,
            child: Card(
              child: ListTile(
                leading: const Icon(
                  Icons.directions,
                  color: AppTheme.secondaryColor,
                ),
                title: Text(
                  '${_formatDistance(_routeResult!.distanceMeters)} - ${_formatDuration(_routeResult!.duration)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Ruta sugerida desde tu ubicacion actual'),
                trailing: IconButton(
                  tooltip: 'Ocultar ruta',
                  icon: const Icon(Icons.close),
                  onPressed: _limpiarRuta,
                ),
              ),
            ),
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
            if (incidente.descripcion != null &&
                incidente.descripcion!.trim().isNotEmpty)
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadingRoute ? null : () => _trazarRuta(incidente),
                icon: _loadingRoute
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.directions),
                label: Text(
                  _loadingRoute
                      ? 'Calculando ruta...'
                      : 'Ver ruta hasta el incidente',
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
