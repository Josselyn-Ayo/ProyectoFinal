import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../providers/incidente_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ReportarIncidentePage extends StatefulWidget {
  const ReportarIncidentePage({super.key});

  @override
  State<ReportarIncidentePage> createState() => _ReportarIncidentePageState();
}

class _ReportarIncidentePageState extends State<ReportarIncidentePage> {
  final _descripcionController = TextEditingController();
  String _tipoSeleccionado = 'robo';
  File? _foto;
  bool _enviando = false;

  final _tiposIncidente = {
    'robo': 'Robo',
    'acoso': 'Acoso',
    'emergencia_medica': 'Emergencia médica',
    'incendio': 'Incendio',
    'accidente': 'Accidente',
    'persona_sospechosa': 'Persona sospechosa',
    'vandalismo': 'Vandalismo',
    'otro': 'Otro',
  };

  @override
  void dispose() {
    _descripcionController.dispose();
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

    final exito = await incidenteProvider.crearIncidente(
      usuarioId: authProvider.userId,
      tipo: _tipoSeleccionado,
      descripcion: _descripcionController.text.isNotEmpty
          ? _descripcionController.text
          : null,
      foto: _foto?.path,
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    if (exito) {
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
          content:
              Text(incidenteProvider.error ?? 'Error al reportar incidente'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tipo de incidente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category),
              ),
              items: _tiposIncidente.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tipoSeleccionado = val);
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
                hintText: 'Describe lo sucedido...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _seleccionarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Adjuntar evidencia'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_foto != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.file(_foto!, height: 150, fit: BoxFit.cover),
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
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : _enviar,
                icon: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(
                    _enviando ? 'ENVIANDO...' : 'ENVIAR REPORTE'),
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
}
