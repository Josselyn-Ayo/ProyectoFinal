import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/services/evidencia_storage_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import '../../../incidente/domain/entities/incidente.dart';

class EvidenciasPage extends StatefulWidget {
  const EvidenciasPage({super.key});

  @override
  State<EvidenciasPage> createState() => _EvidenciasPageState();
}

class _EvidenciasPageState extends State<EvidenciasPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteProvider>().cargarTodosIncidentes();
    });
  }

  Future<void> _tomarFoto(IncidenteEntity incidente) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        final userId = context.read<AuthProvider>().userId;
        if (userId == null) throw StateError('Sesion no valida');
        await EvidenciaStorageService().subirFoto(
          archivo: File(image.path),
          incidenteId: incidente.id,
          usuarioId: userId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Foto registrada para: ${incidente.tipo}')),
        );
      }
    } catch (_) {}
  }

  Color _estadoColor(String estado) {
    switch (estado) {
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

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();
    final guardiaProvider = context.watch<GuardiaProvider>();
    final miGuardia = guardiaProvider.miGuardia;

    final misAtendidos = incidenteProvider.todosIncidentes
        .where((i) =>
            ['Atendido', 'Cerrado'].contains(i.estado) &&
            i.guardiaId == miGuardia?.id)
        .toList();

    if (misAtendidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay incidentes atendidos',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => incidenteProvider.cargarTodosIncidentes(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: misAtendidos.length,
        itemBuilder: (_, i) {
          final inc = misAtendidos[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _estadoColor(inc.estado),
                child: const Icon(Icons.report, color: Colors.white),
              ),
              title: Text(inc.tipo,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_formatDate(inc.fecha)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(inc.estado,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                    backgroundColor: _estadoColor(inc.estado),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: AppTheme.primaryColor),
                    onPressed: () => _tomarFoto(inc),
                    tooltip: 'Registrar evidencia',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
