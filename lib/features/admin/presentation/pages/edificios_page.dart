import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../edificio/domain/entities/edificio.dart';
import '../../../edificio/presentation/providers/edificio_provider.dart';

class AdminEdificiosPage extends StatefulWidget {
  const AdminEdificiosPage({super.key});

  @override
  State<AdminEdificiosPage> createState() => _AdminEdificiosPageState();
}

class _AdminEdificiosPageState extends State<AdminEdificiosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EdificioProvider>().cargarEdificios();
    });
  }

  void _showCreateDialog() {
    final nombreCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final latitudCtrl = TextEditingController();
    final longitudCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Crear Edificio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descripcionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: latitudCtrl,
                  decoration: const InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: longitudCtrl,
                  decoration: const InputDecoration(labelText: 'Longitud'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latitudCtrl.text.trim());
                final lng = double.tryParse(longitudCtrl.text.trim());
                context.read<EdificioProvider>().crearEdificio(
                      nombre: nombreCtrl.text.trim(),
                      descripcion: descripcionCtrl.text.trim().isNotEmpty
                          ? descripcionCtrl.text.trim()
                          : null,
                      latitud: lat,
                      longitud: lng,
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(EdificioEntity edificio) {
    final nombreCtrl = TextEditingController(text: edificio.nombre);
    final descripcionCtrl =
        TextEditingController(text: edificio.descripcion ?? '');
    final latitudCtrl =
        TextEditingController(text: edificio.latitud?.toString() ?? '');
    final longitudCtrl =
        TextEditingController(text: edificio.longitud?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Edificio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descripcionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: latitudCtrl,
                  decoration: const InputDecoration(labelText: 'Latitud'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: longitudCtrl,
                  decoration: const InputDecoration(labelText: 'Longitud'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latitudCtrl.text.trim());
                final lng = double.tryParse(longitudCtrl.text.trim());
                context.read<EdificioProvider>().editarEdificio(
                      id: edificio.id!,
                      nombre: nombreCtrl.text.trim(),
                      descripcion: descripcionCtrl.text.trim().isNotEmpty
                          ? descripcionCtrl.text.trim()
                          : null,
                      latitud: lat,
                      longitud: lng,
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(EdificioEntity edificio) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar Edificio'),
          content: Text('¿Eliminar el edificio "${edificio.nombre}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                context
                    .read<EdificioProvider>()
                    .eliminarEdificio(edificio.id!);
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

  void _showEdificioActions(EdificioEntity edificio) {
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
                Text(edificio.nombre,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                if (edificio.descripcion != null)
                  Text(edificio.descripcion!,
                      style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditDialog(edificio);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete, color: AppTheme.dangerColor),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteDialog(edificio);
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
    final edificioProvider = context.watch<EdificioProvider>();

    if (edificioProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (edificioProvider.edificios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay edificios registrados',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: edificioProvider.edificios.length,
        itemBuilder: (_, i) {
          final edificio = edificioProvider.edificios[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.business, color: Colors.white),
              ),
              title: Text(edificio.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (edificio.descripcion != null) Text(edificio.descripcion!),
                  if (edificio.latitud != null && edificio.longitud != null)
                    Text(
                      '📍 ${edificio.latitud!.toStringAsFixed(4)}, ${edificio.longitud!.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
              onTap: () => _showEdificioActions(edificio),
              onLongPress: () => _showEdificioActions(edificio),
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
