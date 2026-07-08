import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/theme.dart';

class AdminConfiguracionPage extends StatefulWidget {
  const AdminConfiguracionPage({super.key});

  @override
  State<AdminConfiguracionPage> createState() => _AdminConfiguracionPageState();
}

class _AdminConfiguracionPageState extends State<AdminConfiguracionPage> {
  final _nombreCtrl = TextEditingController(text: 'Universidad Nacional');
  final List<TextEditingController> _telefonosCtrl = [
    TextEditingController(text: '+51 123 456 789')
  ];
  final List<TextEditingController> _correosCtrl = [
    TextEditingController(text: 'seguridad@universidad.edu.pe')
  ];
  final ImagePicker _picker = ImagePicker();
  String? _logoPath;

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _logoPath = image.path);
      }
    } catch (_) {}
  }

  void _addTelefono() {
    setState(() => _telefonosCtrl.add(TextEditingController()));
  }

  void _removeTelefono(int index) {
    if (_telefonosCtrl.length > 1) {
      setState(() => _telefonosCtrl.removeAt(index));
    }
  }

  void _addCorreo() {
    setState(() => _correosCtrl.add(TextEditingController()));
  }

  void _removeCorreo(int index) {
    if (_correosCtrl.length > 1) {
      setState(() => _correosCtrl.removeAt(index));
    }
  }

  void _guardar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    for (final c in _telefonosCtrl) {
      c.dispose();
    }
    for (final c in _correosCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Logo de la Universidad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.grey[400]!, width: 1),
                  ),
                  child: _logoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            _logoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Subir logo',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Nombre de la Universidad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                hintText: 'Nombre de la universidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Teléfonos',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                    onPressed: _addTelefono,
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryColor)),
              ],
            ),
            ...List.generate(_telefonosCtrl.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _telefonosCtrl[i],
                        decoration: const InputDecoration(
                          hintText: 'Número de teléfono',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeTelefono(i),
                      icon: const Icon(Icons.remove_circle,
                          color: AppTheme.dangerColor),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Correos Electrónicos',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                    onPressed: _addCorreo,
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryColor)),
              ],
            ),
            ...List.generate(_correosCtrl.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _correosCtrl[i],
                        decoration: const InputDecoration(
                          hintText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeCorreo(i),
                      icon: const Icon(Icons.remove_circle,
                          color: AppTheme.dangerColor),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Configuración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
