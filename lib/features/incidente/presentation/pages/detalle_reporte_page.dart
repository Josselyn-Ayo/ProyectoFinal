import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/widgets/campus_map_widget.dart';
import '../../../../core/widgets/evidencias_gallery.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../domain/entities/incidente.dart';
import '../providers/incidente_provider.dart';

class DetalleReportePage extends StatelessWidget {
  final IncidenteEntity incidente;

  const DetalleReportePage({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {
    final incidentes = context.watch<IncidenteProvider>().misIncidentes;
    final incidenteActual = _findUpdatedIncident(incidentes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento del reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Abrir chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    incidenteId: incidenteActual.id,
                    incidenteTipo: incidenteActual.tipo,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          incidenteActual.tipo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _EstadoChip(estado: incidenteActual.estado),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (incidenteActual.anonimo)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Chip(
                        avatar: Icon(Icons.privacy_tip, size: 18),
                        label: Text('Reporte anonimo'),
                      ),
                    ),
                  if (incidenteActual.descripcion != null &&
                      incidenteActual.descripcion!.trim().isNotEmpty)
                    Text(incidenteActual.descripcion!),
                  if (incidenteActual.ubicacionReferencia != null &&
                      incidenteActual.ubicacionReferencia!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(incidenteActual.ubicacionReferencia!),
                        ),
                      ],
                    ),
                  ],
                  if (incidenteActual.respuestaSeguridad != null &&
                      incidenteActual.respuestaSeguridad!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Respuesta de seguridad',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(incidenteActual.respuestaSeguridad!),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          EvidenciasGallery(
            incidenteId: incidenteActual.id,
            fotoLegada: incidenteActual.foto,
          ),
          const SizedBox(height: 16),
          const Text(
            'Estado del caso',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _TimelineCard(incidente: incidenteActual),
          const SizedBox(height: 16),
          if (incidenteActual.latitud != null &&
              incidenteActual.longitud != null) ...[
            const Text(
              'Ubicacion registrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: CampusMapWidget(
                incidentes: [incidenteActual],
                edificios: const [],
                initialZoom: 17,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    incidenteId: incidenteActual.id,
                    incidenteTipo: incidenteActual.tipo,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text('Abrir chat con seguridad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  IncidenteEntity _findUpdatedIncident(List<IncidenteEntity> incidentes) {
    for (final item in incidentes) {
      if (item.id == incidente.id) {
        return item;
      }
    }
    return incidente;
  }
}

class _TimelineCard extends StatelessWidget {
  final IncidenteEntity incidente;

  const _TimelineCard({required this.incidente});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Reportado', 'Caso recibido por la plataforma'),
      ('Guardia asignado', 'Personal de seguridad acepto el caso'),
      ('En camino', 'El guardia se dirige al punto reportado'),
      ('Atendido', 'El caso fue atendido en sitio'),
      ('Cerrado', 'El incidente se resolvio y cerro'),
    ];

    final currentIndex = steps.indexWhere(
      (step) => step.$1 == incidente.estado,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(steps.length, (index) {
            final active =
                index <= currentIndex || currentIndex == -1 && index == 0;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryColor
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: active
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 42,
                        color: active
                            ? AppTheme.primaryColor
                            : Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index].$1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: active ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[index].$2,
                          style: TextStyle(
                            color: active ? Colors.black54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (estado) {
      case 'Guardia asignado':
        color = AppTheme.primaryColor;
        break;
      case 'En camino':
        color = AppTheme.warningColor;
        break;
      case 'Atendido':
        color = AppTheme.successColor;
        break;
      case 'Cerrado':
        color = Colors.grey;
        break;
      default:
        color = AppTheme.dangerColor;
    }

    return Chip(
      label: Text(estado, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
