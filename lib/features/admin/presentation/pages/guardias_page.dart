import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../guardia/domain/entities/guardia.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';

class AdminGuardiasPage extends StatefulWidget {
  const AdminGuardiasPage({super.key});

  @override
  State<AdminGuardiasPage> createState() => _AdminGuardiasPageState();
}

class _AdminGuardiasPageState extends State<AdminGuardiasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuardiaProvider>().cargarGuardias();
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Disponible':
        return AppTheme.successColor;
      case 'En servicio':
        return AppTheme.warningColor;
      case 'Fuera de servicio':
        return AppTheme.dangerColor;
      default:
        return Colors.grey;
    }
  }

  void _showCreateDialog() {
    final turnoCtrl = TextEditingController();
    String estado = 'Disponible';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Registrar Guardia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: turnoCtrl,
                    decoration: const InputDecoration(labelText: 'Turno'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Disponible', child: Text('Disponible')),
                      DropdownMenuItem(
                          value: 'En servicio', child: Text('En servicio')),
                      DropdownMenuItem(
                          value: 'Fuera de servicio',
                          child: Text('Fuera de servicio')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => estado = v ?? 'Disponible'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    context.read<GuardiaProvider>().registrarGuardia(
                          usuarioId: '',
                          turno: turnoCtrl.text.trim(),
                          estado: estado,
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(GuardiaEntity guardia) {
    final turnoCtrl = TextEditingController(text: guardia.turno ?? '');
    String estado = guardia.estado;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Guardia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: turnoCtrl,
                    decoration: const InputDecoration(labelText: 'Turno'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Disponible', child: Text('Disponible')),
                      DropdownMenuItem(
                          value: 'En servicio', child: Text('En servicio')),
                      DropdownMenuItem(
                          value: 'Fuera de servicio',
                          child: Text('Fuera de servicio')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => estado = v ?? 'Disponible'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    context.read<GuardiaProvider>().editarGuardia(
                          id: guardia.id!,
                          turno: turnoCtrl.text.trim(),
                          estado: estado,
                        );
                    Navigator.pop(ctx);
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

  void _showDeleteDialog(GuardiaEntity guardia) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar Guardia'),
          content: Text(
              '¿Eliminar a ${guardia.usuarioNombre ?? guardia.usuarioId}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                context
                    .read<GuardiaProvider>()
                    .eliminarGuardia(guardia.id!);
                Navigator.pop(ctx);
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

  void _showGuardiaActions(GuardiaEntity guardia) {
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
                Text(guardia.usuarioNombre ?? 'Guardia',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditDialog(guardia);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete, color: AppTheme.dangerColor),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteDialog(guardia);
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
    final guardiaProvider = context.watch<GuardiaProvider>();

    if (guardiaProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (guardiaProvider.guardias.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay guardias registrados',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: guardiaProvider.guardias.length,
        itemBuilder: (_, i) {
          final guardia = guardiaProvider.guardias[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _estadoColor(guardia.estado),
                child: const Icon(Icons.shield, color: Colors.white),
              ),
              title: Text(guardia.usuarioNombre ?? 'Guardia',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (guardia.turno != null) Text('Turno: ${guardia.turno}'),
                  if (guardia.usuarioCorreo != null)
                    Text(guardia.usuarioCorreo!,
                        style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: Chip(
                label: Text(guardia.estado,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 11)),
                backgroundColor: _estadoColor(guardia.estado),
                padding: EdgeInsets.zero,
              ),
              onTap: () => _showGuardiaActions(guardia),
              onLongPress: () => _showGuardiaActions(guardia),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
