import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/edificio/domain/entities/edificio.dart';
import '../../features/incidente/domain/entities/incidente.dart';

class CampusMapWidget extends StatelessWidget {
  final List<IncidenteEntity> incidentes;
  final List<EdificioEntity> edificios;
  final void Function(IncidenteEntity incidente)? onIncidenteTap;
  final void Function(EdificioEntity edificio)? onEdificioTap;
  final double initialZoom;

  const CampusMapWidget({
    super.key,
    required this.incidentes,
    required this.edificios,
    this.onIncidenteTap,
    this.onEdificioTap,
    this.initialZoom = 16,
  });

  @override
  Widget build(BuildContext context) {
    final center = _resolveCenter();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.proyecto_final',
          ),
          MarkerLayer(
            markers: [
              ..._incidentMarkers(),
              ..._buildingMarkers(),
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
    final points = <LatLng>[
      ...incidentes
          .where((incidente) => incidente.latitud != null && incidente.longitud != null)
          .map((incidente) => LatLng(incidente.latitud!, incidente.longitud!)),
      ...edificios
          .where((edificio) => edificio.latitud != null && edificio.longitud != null)
          .map((edificio) => LatLng(edificio.latitud!, edificio.longitud!)),
    ];

    if (points.isEmpty) {
      // Campus principal Jose Ruben Orellana de la EPN, Quito.
      return const LatLng(-0.210145, -78.488712);
    }

    final lat = points.map((point) => point.latitude).reduce((a, b) => a + b) /
        points.length;
    final lng =
        points.map((point) => point.longitude).reduce((a, b) => a + b) /
            points.length;
    return LatLng(lat, lng);
  }

  List<Marker> _incidentMarkers() {
    return incidentes
        .where((incidente) => incidente.latitud != null && incidente.longitud != null)
        .map(
          (incidente) => Marker(
            point: LatLng(incidente.latitud!, incidente.longitud!),
            width: 56,
            height: 56,
            child: GestureDetector(
              onTap: onIncidenteTap != null ? () => onIncidenteTap!(incidente) : null,
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
        .where((edificio) => edificio.latitud != null && edificio.longitud != null)
        .map(
          (edificio) => Marker(
            point: LatLng(edificio.latitud!, edificio.longitud!),
            width: 52,
            height: 52,
            child: GestureDetector(
              onTap: onEdificioTap != null ? () => onEdificioTap!(edificio) : null,
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
