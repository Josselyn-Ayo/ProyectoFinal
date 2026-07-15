import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

  void _showCreateDialog() => _showEdificioDialog();

  void _showEditDialog(EdificioEntity edificio) {
    _showEdificioDialog(edificio: edificio);
  }

  void _showEdificioDialog({EdificioEntity? edificio}) {
    final nombreCtrl = TextEditingController(text: edificio?.nombre ?? '');
    final descripcionCtrl =
        TextEditingController(text: edificio?.descripcion ?? '');
    LatLng? ubicacion = edificio?.latitud != null && edificio?.longitud != null
        ? LatLng(edificio!.latitud!, edificio.longitud!)
        : null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(edificio == null ? 'Crear Edificio' : 'Editar Edificio'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
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
                    decoration: const InputDecoration(labelText: 'Descripcion'),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ubicacion en el campus',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _LocationPickerMap(
                    selectedLocation: ubicacion,
                    onLocationSelected: (location) {
                      setDialogState(() => ubicacion = location);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ubicacion == null
                        ? 'Toca el mapa para marcar el edificio.'
                        : 'Ubicacion seleccionada: ${ubicacion!.latitude.toStringAsFixed(6)}, ${ubicacion!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ubicacion == null
                          ? Colors.grey[700]
                          : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isEmpty || ubicacion == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ingresa un nombre y selecciona la ubicacion en el mapa.',
                      ),
                    ),
                  );
                  return;
                }

                final provider = context.read<EdificioProvider>();
                if (edificio == null) {
                  provider.crearEdificio(
                    nombre: nombreCtrl.text.trim(),
                    descripcion: descripcionCtrl.text.trim().isEmpty
                        ? null
                        : descripcionCtrl.text.trim(),
                    latitud: ubicacion!.latitude,
                    longitud: ubicacion!.longitude,
                  );
                } else {
                  provider.editarEdificio(
                    id: edificio.id!,
                    nombre: nombreCtrl.text.trim(),
                    descripcion: descripcionCtrl.text.trim().isEmpty
                        ? null
                        : descripcionCtrl.text.trim(),
                    latitud: ubicacion!.latitude,
                    longitud: ubicacion!.longitude,
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(edificio == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(EdificioEntity edificio) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Edificio'),
        content: Text('Eliminar el edificio "${edificio.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EdificioProvider>().eliminarEdificio(edificio.id!);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEdificioActions(EdificioEntity edificio) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                edificio.nombre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (edificio.descripcion != null)
                Text(edificio.descripcion!, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditDialog(edificio);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.dangerColor),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showDeleteDialog(edificio);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edificioProvider = context.watch<EdificioProvider>();

    if (edificioProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: edificioProvider.edificios.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay edificios registrados',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: edificioProvider.edificios.length,
              itemBuilder: (_, index) {
                final edificio = edificioProvider.edificios[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(
                      edificio.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (edificio.descripcion != null) Text(edificio.descripcion!),
                        if (edificio.latitud != null && edificio.longitud != null)
                          Text(
                            'Ubicacion: ${edificio.latitud!.toStringAsFixed(4)}, ${edificio.longitud!.toStringAsFixed(4)}',
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

class _LocationPickerMap extends StatelessWidget {
  static const _epnCenter = LatLng(-0.210145, -78.488712);

  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const _LocationPickerMap({
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: selectedLocation ?? _epnCenter,
            initialZoom: 17,
            onTap: (_, location) => onLocationSelected(location),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.proyecto_final',
            ),
            if (selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation!,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.dangerColor,
                      size: 44,
                    ),
                  ),
                ],
              ),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('OpenStreetMap contributors')],
            ),
          ],
        ),
      ),
    );
  }
}
