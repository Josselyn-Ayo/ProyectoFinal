import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../edificio/data/datasources/edificio_remote_datasource.dart';
import '../../../edificio/data/repositories/edificio_repository_impl.dart';
import '../../../edificio/domain/usecases/get_edificios.dart';
import '../../../edificio/domain/usecases/crear_edificio.dart';
import '../../../edificio/domain/usecases/editar_edificio.dart';
import '../../../edificio/domain/usecases/eliminar_edificio.dart';
import '../providers/edificio_provider.dart';
import '../../domain/entities/edificio.dart';

class EdificiosPage extends StatefulWidget {
  const EdificiosPage({super.key});

  @override
  State<EdificiosPage> createState() => _EdificiosPageState();
}

class _EdificiosPageState extends State<EdificiosPage> {
  late EdificioProvider _provider;

  @override
  void initState() {
    super.initState();
    final datasource = EdificioRemoteDataSourceImpl();
    final repository = EdificioRepositoryImpl(remoteDataSource: datasource);
    _provider = EdificioProvider(
      getEdificiosUseCase: GetEdificiosUseCase(repository),
      crearEdificioUseCase: CrearEdificioUseCase(repository),
      editarEdificioUseCase: EditarEdificioUseCase(repository),
      eliminarEdificioUseCase: EliminarEdificioUseCase(repository),
    );
    _provider.cargarEdificios();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edificios')),
        body: Consumer<EdificioProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.edificios.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.edificios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
                    const SizedBox(height: 16),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.cargarEdificios(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.edificios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay edificios registrados',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.cargarEdificios(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.edificios.length,
                itemBuilder: (context, index) {
                  return _EdificioCard(edificio: provider.edificios[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EdificioCard extends StatelessWidget {
  final EdificioEntity edificio;

  const _EdificioCard({required this.edificio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    edificio.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (edificio.descripcion != null && edificio.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(edificio.descripcion!, style: const TextStyle(fontSize: 14)),
            ],
            if (edificio.latitud != null && edificio.longitud != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.secondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${edificio.latitud!.toStringAsFixed(5)}, ${edificio.longitud!.toStringAsFixed(5)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
