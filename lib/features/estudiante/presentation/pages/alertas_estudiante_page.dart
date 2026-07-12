import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../alerta/domain/entities/alerta.dart';
import '../../../alerta/presentation/providers/alerta_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
    final user = context.watch<AuthProvider>().user;
    final alertas = alertaProvider.alertas
        .where((alerta) => _shouldShowAlert(alerta, user))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: alertaProvider.loading && alertas.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : alertas.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay alertas disponibles',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                    itemCount: alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertas[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _iconForType(alerta.tipo),
                                    color: _colorForType(alerta.tipo),
                                    size: 20,
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
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoChip(label: alerta.tipo.toUpperCase()),
                                  _InfoChip(label: alerta.audiencia.toUpperCase()),
                                  if (alerta.facultadObjetivo != null &&
                                      alerta.facultadObjetivo!.trim().isNotEmpty)
                                    _InfoChip(label: alerta.facultadObjetivo!),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(alerta.mensaje, style: const TextStyle(fontSize: 15)),
                              if (alerta.programada && alerta.fechaProgramada != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
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

  bool _shouldShowAlert(AlertaEntity alerta, UserEntity? user) {
    if (!alerta.activa) return false;
    if (alerta.programada &&
        alerta.fechaProgramada != null &&
        alerta.fechaProgramada!.isAfter(DateTime.now())) {
      return false;
    }

    switch (alerta.audiencia) {
      case 'todos':
      case 'estudiantes':
        return true;
      case 'facultad':
        final facultadUsuario = user?.facultad?.trim().toLowerCase();
        final facultadObjetivo = alerta.facultadObjetivo?.trim().toLowerCase();
        return facultadUsuario != null &&
            facultadUsuario.isNotEmpty &&
            facultadObjetivo != null &&
            facultadObjetivo.isNotEmpty &&
            facultadUsuario == facultadObjetivo;
      default:
        return false;
    }
  }

  IconData _iconForType(String tipo) {
    switch (tipo) {
      case 'urgente':
        return Icons.warning_amber_rounded;
      case 'preventiva':
        return Icons.shield_outlined;
      case 'simulacro':
        return Icons.event_note;
      default:
        return Icons.campaign;
    }
  }

  Color _colorForType(String tipo) {
    switch (tipo) {
      case 'urgente':
        return AppTheme.dangerColor;
      case 'preventiva':
        return AppTheme.successColor;
      case 'simulacro':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.warningColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
