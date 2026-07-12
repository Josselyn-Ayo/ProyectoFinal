import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  List<UserEntity> _usuarios = [];
  List<UserEntity> _filtered = [];
  bool _loading = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _loading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      _usuarios = await authProvider.getAllUsers();
      _filtered = List.from(_usuarios);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _filter(String query) {
    setState(() {
      _filtered = _usuarios
          .where((u) =>
              u.nombre.toLowerCase().contains(query.toLowerCase()) ||
              u.apellido.toLowerCase().contains(query.toLowerCase()) ||
              u.correo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Color _rolColor(String rol) {
    switch (rol) {
      case 'admin':
        return AppTheme.primaryColor;
      case 'seguridad':
        return AppTheme.warningColor;
      default:
        return AppTheme.successColor;
    }
  }

  void _showCreateDialog() {
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final facultadCtrl = TextEditingController();
    final carreraCtrl = TextEditingController();
    String rol = 'estudiante';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nombreCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Nombre')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: apellidoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Apellido')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: correoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Correo')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: passwordCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Contraseña'),
                        obscureText: true),
                    const SizedBox(height: 8),
                    TextField(
                        controller: telefonoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Teléfono')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: facultadCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Facultad')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: carreraCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Carrera')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: rol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(
                            value: 'estudiante',
                            child: Text('Estudiante')),
                        DropdownMenuItem(
                            value: 'seguridad',
                            child: Text('Seguridad')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => rol = v ?? 'estudiante'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<AuthProvider>().createUser(
                            email: correoCtrl.text.trim(),
                            password: passwordCtrl.text.trim(),
                            nombre: nombreCtrl.text.trim(),
                            apellido: apellidoCtrl.text.trim(),
                            rol: rol,
                            telefono: telefonoCtrl.text.trim().isNotEmpty
                                ? telefonoCtrl.text.trim()
                                : null,
                            facultad: facultadCtrl.text.trim().isNotEmpty
                                ? facultadCtrl.text.trim()
                                : null,
                            carrera: carreraCtrl.text.trim().isNotEmpty
                                ? carreraCtrl.text.trim()
                                : null,
                          );
                      Navigator.pop(ctx);
                      _cargarUsuarios();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(UserEntity user) {
    final nombreCtrl = TextEditingController(text: user.nombre);
    final apellidoCtrl = TextEditingController(text: user.apellido);
    final correoCtrl = TextEditingController(text: user.correo);
    final telefonoCtrl = TextEditingController(text: user.telefono ?? '');
    final facultadCtrl = TextEditingController(text: user.facultad ?? '');
    final carreraCtrl = TextEditingController(text: user.carrera ?? '');
    String rol = user.rol;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nombreCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Nombre')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: apellidoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Apellido')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: correoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Correo')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: telefonoCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Teléfono')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: facultadCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Facultad')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: carreraCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Carrera')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: rol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(
                            value: 'estudiante',
                            child: Text('Estudiante')),
                        DropdownMenuItem(
                            value: 'seguridad',
                            child: Text('Seguridad')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => rol = v ?? 'estudiante'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final updated = user.copyWith(
                        nombre: nombreCtrl.text.trim(),
                        apellido: apellidoCtrl.text.trim(),
                        correo: correoCtrl.text.trim(),
                        telefono: telefonoCtrl.text.trim().isNotEmpty
                            ? telefonoCtrl.text.trim()
                            : null,
                        facultad: facultadCtrl.text.trim().isNotEmpty
                            ? facultadCtrl.text.trim()
                            : null,
                        carrera: carreraCtrl.text.trim().isNotEmpty
                            ? carreraCtrl.text.trim()
                            : null,
                        rol: rol,
                      );
                      await context
                          .read<AuthProvider>()
                          .updateUser(updated);
                      Navigator.pop(ctx);
                      _cargarUsuarios();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: Text('¿Eliminar a ${user.nombreCompleto}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthProvider>()
                    .deleteUser(user.id);
                Navigator.pop(ctx);
                _cargarUsuarios();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerColor),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showUserActions(UserEntity user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(user.nombreCompleto,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user.correo,
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditDialog(user);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete, color: AppTheme.dangerColor),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteDialog(user);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, apellido o correo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No se encontraron usuarios',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final user = _filtered[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _rolColor(user.rol),
                                child: Text(
                                  user.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(user.nombreCompleto,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(user.correo),
                              trailing: Chip(
                                label: Text(user.rol,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11)),
                                backgroundColor: _rolColor(user.rol),
                                padding: EdgeInsets.zero,
                              ),
                              onTap: () => _showUserActions(user),
                              onLongPress: () => _showUserActions(user),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
