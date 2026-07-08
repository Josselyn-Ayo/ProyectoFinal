import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../providers/incidente_provider.dart';

class SosPage extends StatefulWidget {
  final String usuarioId;

  const SosPage({super.key, required this.usuarioId});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final _descripcionController = TextEditingController();
  String _tipoSeleccionado = 'robo';
  File? _foto;
  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;
  bool _enviando = false;

  final _tiposEmergencia = {
    'robo': 'Robo',
    'acoso': 'Acoso',
    'emergencia_medica': 'Emergencia médica',
    'incendio': 'Incendio',
    'accidente': 'Accidente',
    'persona_sospechosa': 'Persona sospechosa',
    'otro': 'Otro',
  };

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _obteniendoUbicacion = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El GPS está desactivado')),
          );
        }
        setState(() => _obteniendoUbicacion = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de ubicación denegado')),
            );
          }
          setState(() => _obteniendoUbicacion = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Permiso de ubicación denegado permanentemente')),
          );
        }
        setState(() => _obteniendoUbicacion = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
        _obteniendoUbicacion = false;
      });
    } catch (e) {
      setState(() => _obteniendoUbicacion = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _foto = File(pickedFile.path));
    }
  }

  Future<void> _enviarEmergencia() async {
    if (_enviando) return;

    setState(() => _enviando = true);

    final provider = context.read<IncidenteProvider>();
    final exito = await provider.crearIncidente(
      usuarioId: widget.usuarioId,
      tipo: _tipoSeleccionado,
      descripcion: _descripcionController.text.isNotEmpty
          ? _descripcionController.text
          : null,
      latitud: _latitud,
      longitud: _longitud,
      foto: _foto?.path,
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    if (exito) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
              SizedBox(width: 8),
              Text('Emergencia enviada'),
            ],
          ),
          content: const Text(
            'Tu reporte de emergencia ha sido enviado. Seguridad universitaria responderá a la brevedad.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al enviar la emergencia'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS - Emergencia'),
        backgroundColor: AppTheme.dangerColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.dangerColor.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppTheme.dangerColor, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solo usa este botón en caso de emergencia real. Se notificará de inmediato al equipo de seguridad.',
                      style: TextStyle(
                          color: AppTheme.dangerColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Tipo de emergencia',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category),
              ),
              items: _tiposEmergencia.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _tipoSeleccionado = val);
                }
              },
            ),
            const SizedBox(height: 16),

            const Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe la emergencia...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _seleccionarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Adjuntar foto'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _obteniendoUbicacion ? null : _obtenerUbicacion,
                    icon: _obteniendoUbicacion
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on),
                    label: Text(_latitud != null
                        ? 'Ubicación lista'
                        : 'Obtener ubicación'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            if (_foto != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.file(
                      _foto!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () => setState(() => _foto = null),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : _enviarEmergencia,
                icon: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.warning, size: 28),
                label: Text(
                  _enviando ? 'ENVIANDO...' : 'ENVIAR EMERGENCIA',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
