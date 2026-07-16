import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/services/evidencia_storage_service.dart';
import '../../../../core/widgets/evidencias_gallery.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/campus_map_widget.dart';
import '../../../incidente/domain/entities/incidente.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import 'chat_page.dart';

class AtenderCasoPage extends StatefulWidget {
  final IncidenteEntity incidente;

  const AtenderCasoPage({super.key, required this.incidente});

  @override
  State<AtenderCasoPage> createState() => _AtenderCasoPageState();
}

class _AtenderCasoPageState extends State<AtenderCasoPage> {
  late IncidenteEntity _incidente;
  final ImagePicker _picker = ImagePicker();
  int _evidenciasVersion = 0;

  @override
  void initState() {
    super.initState();
    _incidente = widget.incidente;
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

  void _cerrarCaso() {
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
              onPressed: () async {
                final guardiaProvider = context.read<GuardiaProvider>();
                final miGuardia = guardiaProvider.miGuardia;
                context.read<IncidenteProvider>().actualizarEstado(
                  _incidente.id,
                  'Cerrado',
                  guardiaId: miGuardia?.id,
                  respuesta: respuestaCtrl.text.trim().isEmpty
                      ? null
                      : respuestaCtrl.text.trim(),
                );
                if (miGuardia?.id != null) {
                  await guardiaProvider.actualizarEstado(
                    guardiaId: miGuardia!.id!,
                    estado: 'Disponible',
                  );
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                setState(() {
                  _incidente = _incidente.copyWith(
                    estado: 'Cerrado',
                    respuestaSeguridad: respuestaCtrl.text.trim().isEmpty
                        ? null
                        : respuestaCtrl.text.trim(),
                  );
                });
              },
              child: const Text('Cerrar caso'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _subirEvidencia() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (!mounted || image == null) return;
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) throw StateError('Sesion no valida');
      await EvidenciaStorageService().subirFoto(
        archivo: File(image.path),
        incidenteId: _incidente.id,
        usuarioId: userId,
      );
      if (!mounted) return;
      setState(() => _evidenciasVersion++);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia subida correctamente')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo subir la evidencia')),
        );
      }
    }
  }

  ButtonStyle _actionButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guardiaProvider = context.watch<GuardiaProvider>();
    final miGuardia = guardiaProvider.miGuardia;
    final esMiCaso = _incidente.guardiaId == miGuardia?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Atender Caso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            _incidente.tipo,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            _incidente.estado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _estadoColor(_incidente.estado),
                        ),
                      ],
                    ),
                    const Divider(),
                    _detailRow(
                      'Usuario',
                      _incidente.anonimo
                          ? 'Anonimo'
                          : _incidente.usuarioNombre ?? 'N/A',
                    ),
                    _detailRow('Fecha', _formatDate(_incidente.fecha)),
                    _detailRow('Prioridad', _incidente.prioridad ?? 'Media'),
                    _detailRow('Anonimo', _incidente.anonimo ? 'Si' : 'No'),
                    if (_incidente.ubicacionReferencia != null &&
                        _incidente.ubicacionReferencia!.trim().isNotEmpty)
                      _detailRow('Referencia', _incidente.ubicacionReferencia!),
                    if (_incidente.descripcion != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Descripción',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(_incidente.descripcion!),
                    ],
                  ],
                ),
              ),
            ),
            EvidenciasGallery(
              key: ValueKey(_evidenciasVersion),
              incidenteId: _incidente.id,
              fotoLegada: _incidente.foto,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (_incidente.latitud != null &&
                        _incidente.longitud != null)
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: CampusMapWidget(
                          incidentes: [_incidente],
                          edificios: const [],
                          initialZoom: 17,
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Este incidente no tiene coordenadas registradas',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_incidente.estado != 'Cerrado') ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_incidente.estado == 'Guardia asignado' && esMiCaso)
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<IncidenteProvider>().actualizarEstado(
                          _incidente.id,
                          'En camino',
                          guardiaId: miGuardia?.id,
                        );
                        setState(() {
                          _incidente = _incidente.copyWith(estado: 'En camino');
                        });
                      },
                      icon: const Icon(Icons.directions_walk),
                      label: const Text('En camino'),
                      style: _actionButtonStyle(AppTheme.warningColor),
                    ),
                  if (_incidente.estado == 'En camino' && esMiCaso)
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<IncidenteProvider>().actualizarEstado(
                          _incidente.id,
                          'Atendido',
                          guardiaId: miGuardia?.id,
                        );
                        setState(() {
                          _incidente = _incidente.copyWith(estado: 'Atendido');
                        });
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Atendido'),
                      style: _actionButtonStyle(AppTheme.successColor),
                    ),
                  if (_incidente.estado == 'Atendido' && esMiCaso)
                    ElevatedButton.icon(
                      onPressed: _cerrarCaso,
                      icon: const Icon(Icons.lock),
                      label: const Text('Cerrar caso'),
                      style: _actionButtonStyle(Colors.grey[700]!),
                    ),
                  if (_incidente.estado == 'Reportado')
                    ElevatedButton.icon(
                      onPressed: () async {
                        final incidenteProvider = context
                            .read<IncidenteProvider>();
                        final guardiaId = miGuardia?.id;
                        final accepted = await incidenteProvider
                            .reclamarIncidente(_incidente.id);
                        if (!mounted || !context.mounted) return;
                        if (accepted) {
                          setState(() {
                            _incidente = _incidente.copyWith(
                              estado: 'Guardia asignado',
                              guardiaId: guardiaId,
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                incidenteProvider.error ??
                                    'El caso ya no esta disponible',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Aceptar Caso'),
                      style: _actionButtonStyle(AppTheme.primaryColor),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(incidenteId: _incidente.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat con usuario'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _subirEvidencia,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Subir evidencia'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
