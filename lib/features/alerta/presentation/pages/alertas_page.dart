import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme.dart';
import '../../../alerta/data/datasources/alerta_remote_datasource.dart';
import '../../../alerta/data/repositories/alerta_repository_impl.dart';
import '../../../alerta/domain/usecases/get_alertas.dart';
import '../../../alerta/domain/usecases/crear_alerta.dart';
import '../../../alerta/domain/usecases/editar_alerta.dart';
import '../../../alerta/domain/usecases/eliminar_alerta.dart';
import '../providers/alerta_provider.dart';
import '../../domain/entities/alerta.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  late AlertaProvider _provider;

  @override
  void initState() {
    super.initState();
    final datasource = AlertaRemoteDataSourceImpl();
    final repository = AlertaRepositoryImpl(remoteDataSource: datasource);
    _provider = AlertaProvider(
      getAlertasUseCase: GetAlertasUseCase(repository),
      crearAlertaUseCase: CrearAlertaUseCase(repository),
      editarAlertaUseCase: EditarAlertaUseCase(repository),
      eliminarAlertaUseCase: EliminarAlertaUseCase(repository),
    );
    _provider.cargarAlertas();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Alertas')),
        body: Consumer<AlertaProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.alertas.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.alertas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
                    const SizedBox(height: 16),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.cargarAlertas(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.alertas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay alertas disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.cargarAlertas(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.alertas.length,
                itemBuilder: (context, index) {
                  return _AlertaCard(alerta: provider.alertas[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final AlertaEntity alerta;

  const _AlertaCard({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  alerta.programada ? Icons.schedule : Icons.notifications_active,
                  color: alerta.programada ? AppTheme.warningColor : AppTheme.dangerColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alerta.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (alerta.programada)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Programada',
                      style: TextStyle(fontSize: 11, color: AppTheme.warningColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(alerta.mensaje, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            if (alerta.fecha != null)
              Text(
                'Fecha: ${dateFormat.format(alerta.fecha!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (alerta.fechaProgramada != null)
              Text(
                'Programado para: ${dateFormat.format(alerta.fechaProgramada!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
