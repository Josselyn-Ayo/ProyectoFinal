import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/config/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  late TextEditingController _carreraController;
  late TextEditingController _facultadController;
  late TextEditingController _contactoEmergenciaController;

  String? _fotoPath;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nombreController = TextEditingController(text: user?.nombre ?? '');
    _apellidoController = TextEditingController(text: user?.apellido ?? '');
    _telefonoController = TextEditingController(text: user?.telefono ?? '');
    _carreraController = TextEditingController(text: user?.carrera ?? '');
    _facultadController = TextEditingController(text: user?.facultad ?? '');
    _contactoEmergenciaController =
        TextEditingController(text: user?.contactoEmergencia ?? '');
    _fotoPath = user?.foto;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _carreraController.dispose();
    _facultadController.dispose();
    _contactoEmergenciaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _fotoPath = pickedFile.path);
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final auth = context.read<AuthProvider>();
      final currentUser = auth.user;
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        carrera: _carreraController.text.trim().isEmpty
            ? null
            : _carreraController.text.trim(),
        facultad: _facultadController.text.trim().isEmpty
            ? null
            : _facultadController.text.trim(),
        contactoEmergencia:
            _contactoEmergenciaController.text.trim().isEmpty
                ? null
                : _contactoEmergenciaController.text.trim(),
        foto: _fotoPath,
      );

      await auth.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildFotoSelector(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carreraController,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facultadController,
                decoration: const InputDecoration(
                  labelText: 'Facultad',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactoEmergenciaController,
                decoration: const InputDecoration(
                  labelText: 'Contacto de Emergencia',
                  prefixIcon: Icon(Icons.emergency),
                  hintText: 'Nombre y teléfono de contacto',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFotoSelector() {
    return GestureDetector(
      onTap: _seleccionarFoto,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            backgroundImage:
                _fotoPath != null && File(_fotoPath!).existsSync()
                    ? FileImage(File(_fotoPath!))
                    : null,
            child: _fotoPath == null || !File(_fotoPath!).existsSync()
                ? const Icon(Icons.camera_alt,
                    size: 40, color: AppTheme.primaryColor)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.edit, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
