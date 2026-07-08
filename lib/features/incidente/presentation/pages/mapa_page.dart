import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/incidente_provider.dart';

class MapaIncidentePage extends StatelessWidget {
  const MapaIncidentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Incidentes')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Mapa en construcción',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<IncidenteProvider>().cargarIncidentesActivos();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Cargar incidentes'),
            ),
          ],
        ),
      ),
    );
  }
}
