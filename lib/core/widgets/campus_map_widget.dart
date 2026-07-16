import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/edificio/domain/entities/edificio.dart';
import '../../features/incidente/domain/entities/incidente.dart';

enum CampusMapMode { marcadores, calor }

class CampusMapWidget extends StatelessWidget {
  final List<IncidenteEntity> incidentes;
  final List<EdificioEntity> edificios;
  final void Function(IncidenteEntity incidente)? onIncidenteTap;
  final void Function(EdificioEntity edificio)? onEdificioTap;
  final double initialZoom;
  final CampusMapMode mode;
  final List<LatLng> routePoints;
  final LatLng? guardLocation;

  const CampusMapWidget({
    super.key,
    required this.incidentes,
    required this.edificios,
    this.onIncidenteTap,
    this.onEdificioTap,
    this.initialZoom = 16,
    this.mode = CampusMapMode.marcadores,
    this.routePoints = const [],
    this.guardLocation,
  });

  @override
  Widget build(BuildContext context) {
    final center = _resolveCenter();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: initialZoom),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.proyecto_final',
          ),
          if (mode == CampusMapMode.calor)
            CircleLayer(circles: _heatmapCircles())
          else
            MarkerLayer(markers: _incidentMarkers()),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 6,
                  color: const Color(0xFF006E75),
                  borderStrokeWidth: 2,
                  borderColor: Colors.white,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              ..._buildingMarkers(),
              if (guardLocation != null)
                Marker(
                  point: guardLocation!,
                  width: 56,
                  height: 56,
                  child: const _MapMarker(
                    icon: Icons.my_location,
                    color: Color(0xFF006E75),
                    tooltip: 'Tu ubicacion',
                  ),
                ),
            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LatLng _resolveCenter() {
    final guardPoints = guardLocation == null
        ? const <LatLng>[]
        : <LatLng>[guardLocation!];
    final points = <LatLng>[
      ...incidentes
          .where(
            (incidente) =>
                incidente.latitud != null && incidente.longitud != null,
          )
          .map((incidente) => LatLng(incidente.latitud!, incidente.longitud!)),
      ...edificios
          .where(
            (edificio) => edificio.latitud != null && edificio.longitud != null,
          )
          .map((edificio) => LatLng(edificio.latitud!, edificio.longitud!)),
      ...routePoints,
      ...guardPoints,
    ];

    if (points.isEmpty) {
      // Campus principal Jose Ruben Orellana de la EPN, Quito.
      return const LatLng(-0.210145, -78.488712);
    }

    final lat =
        points.map((point) => point.latitude).reduce((a, b) => a + b) /
        points.length;
    final lng =
        points.map((point) => point.longitude).reduce((a, b) => a + b) /
        points.length;
    return LatLng(lat, lng);
  }

  List<Marker> _incidentMarkers() {
    return incidentes
        .where(
          (incidente) =>
              incidente.latitud != null && incidente.longitud != null,
        )
        .map(
          (incidente) => Marker(
            point: LatLng(incidente.latitud!, incidente.longitud!),
            width: 56,
            height: 56,
            child: GestureDetector(
              onTap: onIncidenteTap != null
                  ? () => onIncidenteTap!(incidente)
                  : null,
              child: const _MapMarker(
                icon: Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F),
                tooltip: 'Incidente',
              ),
            ),
          ),
        )
        .toList();
  }

  List<Marker> _buildingMarkers() {
    return edificios
        .where(
          (edificio) => edificio.latitud != null && edificio.longitud != null,
        )
        .map(
          (edificio) => Marker(
            point: LatLng(edificio.latitud!, edificio.longitud!),
            width: 52,
            height: 52,
            child: GestureDetector(
              onTap: onEdificioTap != null
                  ? () => onEdificioTap!(edificio)
                  : null,
              child: Tooltip(
                message: edificio.nombre,
                child: const _MapMarker(
                  icon: Icons.business,
                  color: Color(0xFF2E7D32),
                  tooltip: 'Edificio',
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  List<CircleMarker> _heatmapCircles() {
    final cells = <String, _HeatCell>{};
    for (final incidente in incidentes) {
      if (incidente.latitud == null || incidente.longitud == null) continue;
      const cellSize = 0.0007;
      final latCell = (incidente.latitud! / cellSize).round();
      final lngCell = (incidente.longitud! / cellSize).round();
      final key = '$latCell:$lngCell';
      final weight = switch (incidente.prioridad) {
        'Alta' => 3,
        'Media' => 2,
        _ => 1,
      };
      cells.update(
        key,
        (cell) => cell.add(incidente.latitud!, incidente.longitud!, weight),
        ifAbsent: () => _HeatCell(
          latitude: incidente.latitud!,
          longitude: incidente.longitud!,
          weight: weight,
        ),
      );
    }

    return cells.values.map((cell) {
      final intensity = (cell.weight / 6).clamp(0.25, 1.0);
      final color = Color.lerp(
        const Color(0xFFFFC107),
        const Color(0xFFD32F2F),
        intensity,
      )!;
      return CircleMarker(
        point: LatLng(cell.latitude, cell.longitude),
        radius: 42 + (cell.weight * 14),
        useRadiusInMeter: true,
        color: color.withValues(alpha: 0.20 + (intensity * 0.45)),
        borderColor: color.withValues(alpha: 0.75),
        borderStrokeWidth: 2,
      );
    }).toList();
  }
}

class _HeatCell {
  double latitude;
  double longitude;
  int weight;
  int count;

  _HeatCell({
    required this.latitude,
    required this.longitude,
    required this.weight,
  }) : count = 1;

  _HeatCell add(double nextLatitude, double nextLongitude, int nextWeight) {
    latitude = ((latitude * count) + nextLatitude) / (count + 1);
    longitude = ((longitude * count) + nextLongitude) / (count + 1);
    weight += nextWeight;
    count++;
    return this;
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;

  const _MapMarker({
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
