import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../alerta/presentation/providers/alerta_provider.dart';

class AlertasEstudiantePage extends StatefulWidget {
  const AlertasEstudiantePage({super.key});

  @override
  State<AlertasEstudiantePage> createState() => _AlertasEstudiantePageState();
}

class _AlertasEstudiantePageState extends State<AlertasEstudiantePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertaProvider>().cargarAlertas();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AlertaProvider>().cargarAlertas();
  }

  @override
  Widget build(BuildContext context) {
    final alertaProvider = context.watch<AlertaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: alertaProvider.loading && alertaProvider.alertas.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : alertaProvider.alertas.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay alertas disponibles',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Desliza hacia abajo para recargar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alertaProvider.alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertaProvider.alertas[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.campaign,
                                      color: AppTheme.warningColor, size: 20),
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
                                  if (alerta.fecha != null)
                                    Text(
                                      _formatDate(alerta.fecha!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                alerta.mensaje,
                                style: const TextStyle(fontSize: 15),
                              ),
                              if (alerta.programada &&
                                  alerta.fechaProgramada != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Programada: ${_formatDate(alerta.fechaProgramada!)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
