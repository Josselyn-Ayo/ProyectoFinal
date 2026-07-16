import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/services/evidencia_storage_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/incidente_provider.dart';

class ReportarIncidentePage extends StatefulWidget {
  const ReportarIncidentePage({super.key});

  @override
  State<ReportarIncidentePage> createState() => _ReportarIncidentePageState();
}

class _ReportarIncidentePageState extends State<ReportarIncidentePage> {
  final _descripcionController = TextEditingController();
  final _ubicacionReferenciaController = TextEditingController();
  String _tipoSeleccionado = 'robo';
  File? _foto;
  bool _enviando = false;
  bool _anonimo = false;

  final _tiposIncidente = {
    'robo': 'Robo',
    'acoso': 'Acoso',
    'emergencia_medica': 'Emergencia medica',
    'incendio': 'Incendio',
    'accidente': 'Accidente',
    'persona_sospechosa': 'Persona sospechosa',
    'vandalismo': 'Vandalismo',
    'otro': 'Otro',
  };

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionReferenciaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _foto = File(pickedFile.path));
    }
  }

  Future<void> _enviar() async {
    if (_enviando) return;

    setState(() => _enviando = true);

    final authProvider = context.read<AuthProvider>();
    final incidenteProvider = context.read<IncidenteProvider>();

    final incidente = await incidenteProvider.crearIncidente(
      usuarioId: authProvider.userId,
      tipo: _tipoSeleccionado,
      descripcion: _descripcionController.text.isNotEmpty
          ? _descripcionController.text
          : null,
      foto: null,
      anonimo: _anonimo,
      ubicacionReferencia: _ubicacionReferenciaController.text.trim().isEmpty
          ? null
          : _ubicacionReferenciaController.text.trim(),
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    if (incidente != null) {
      if (_foto != null && authProvider.userId != null) {
        try {
          await EvidenciaStorageService().subirFoto(
            archivo: _foto!,
            incidenteId: incidente.id,
            usuarioId: authProvider.userId!,
          );
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'El reporte se envio, pero la evidencia no pudo cargarse.',
                ),
              ),
            );
          }
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidente reportado exitosamente'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            incidenteProvider.error ?? 'Error al reportar incidente',
          ),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar incidente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paso 1 de 1',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text('Detalles', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              value: 1,
              minHeight: 8,
              borderRadius: BorderRadius.all(Radius.circular(99)),
              color: AppTheme.secondaryColor,
              backgroundColor: AppTheme.softBlue,
            ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Qué tipo de incidente?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tipoSeleccionado,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _tiposIncidente.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _tipoSeleccionado = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Describe lo sucedido',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descripcionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Incluye los detalles que puedan ayudar a seguridad...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 8),
                        Text(
                          'Ubicación',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ubicacionReferenciaController,
                      decoration: const InputDecoration(
                        labelText: 'Referencia del campus',
                        hintText: 'Ej. Coliseo, laboratorios, entrada sur',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _seleccionarFoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        _foto == null
                            ? 'Adjuntar evidencia'
                            : 'Cambiar evidencia',
                      ),
                    ),
                    if (_foto != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.file(
                              _foto!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () => setState(() => _foto = null),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                value: _anonimo,
                onChanged: (value) => setState(() => _anonimo = value),
                activeTrackColor: AppTheme.secondaryColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: const Text(
                  'Reporte anónimo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Protege tu identidad en casos sensibles.',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : _enviar,
                icon: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_enviando ? 'ENVIANDO...' : 'ENVIAR REPORTE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
