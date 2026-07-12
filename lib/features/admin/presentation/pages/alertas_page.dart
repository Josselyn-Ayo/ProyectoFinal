import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../alerta/domain/entities/alerta.dart';
import '../../../alerta/presentation/providers/alerta_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminAlertasPage extends StatefulWidget {
  const AdminAlertasPage({super.key});

  @override
  State<AdminAlertasPage> createState() => _AdminAlertasPageState();
}

class _AdminAlertasPageState extends State<AdminAlertasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertaProvider>().cargarAlertas();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Future<void> _showCreateDialog() async {
    final tituloCtrl = TextEditingController();
    final mensajeCtrl = TextEditingController();
    final facultadCtrl = TextEditingController();
    bool programada = false;
    bool activa = true;
    DateTime? fechaProgramada;
    String tipo = 'informativa';
    String audiencia = 'todos';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Crear alerta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Titulo'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: mensajeCtrl,
                      decoration: const InputDecoration(labelText: 'Mensaje'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tipo,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(value: 'informativa', child: Text('Informativa')),
                        DropdownMenuItem(value: 'preventiva', child: Text('Preventiva')),
                        DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                        DropdownMenuItem(value: 'simulacro', child: Text('Simulacro')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => tipo = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: audiencia,
                      decoration: const InputDecoration(labelText: 'Audiencia'),
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text('Todos')),
                        DropdownMenuItem(value: 'estudiantes', child: Text('Estudiantes')),
                        DropdownMenuItem(value: 'seguridad', child: Text('Seguridad')),
                        DropdownMenuItem(value: 'admin', child: Text('Administracion')),
                        DropdownMenuItem(value: 'facultad', child: Text('Por facultad')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => audiencia = value);
                      },
                    ),
                    if (audiencia == 'facultad') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: facultadCtrl,
                        decoration: const InputDecoration(labelText: 'Facultad objetivo'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Alerta activa'),
                      value: activa,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setDialogState(() => activa = value),
                    ),
                    SwitchListTile(
                      title: const Text('Programada'),
                      value: programada,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setDialogState(() => programada = value),
                    ),
                    if (programada)
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          fechaProgramada != null
                              ? _formatDate(fechaProgramada)
                              : 'Seleccionar fecha y hora',
                        ),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate == null || !mounted) return;

                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime == null) return;

                          setDialogState(() {
                            fechaProgramada = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (tituloCtrl.text.trim().isEmpty ||
                        mensajeCtrl.text.trim().isEmpty) {
                      return;
                    }

                    final auth = context.read<AuthProvider>();
                    await context.read<AlertaProvider>().crearAlerta(
                          titulo: tituloCtrl.text.trim(),
                          mensaje: mensajeCtrl.text.trim(),
                          creadorId: auth.userId ?? '',
                          programada: programada,
                          fechaProgramada: fechaProgramada,
                          tipo: tipo,
                          audiencia: audiencia,
                          facultadObjetivo: facultadCtrl.text.trim().isEmpty
                              ? null
                              : facultadCtrl.text.trim(),
                          activa: activa,
                        );

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
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

  Future<void> _showEditDialog(AlertaEntity alerta) async {
    final tituloCtrl = TextEditingController(text: alerta.titulo);
    final mensajeCtrl = TextEditingController(text: alerta.mensaje);
    final facultadCtrl = TextEditingController(text: alerta.facultadObjetivo ?? '');
    bool programada = alerta.programada;
    bool activa = alerta.activa;
    DateTime? fechaProgramada = alerta.fechaProgramada;
    String tipo = alerta.tipo;
    String audiencia = alerta.audiencia;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Editar alerta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Titulo'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: mensajeCtrl,
                      decoration: const InputDecoration(labelText: 'Mensaje'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tipo,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(value: 'informativa', child: Text('Informativa')),
                        DropdownMenuItem(value: 'preventiva', child: Text('Preventiva')),
                        DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                        DropdownMenuItem(value: 'simulacro', child: Text('Simulacro')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => tipo = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: audiencia,
                      decoration: const InputDecoration(labelText: 'Audiencia'),
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text('Todos')),
                        DropdownMenuItem(value: 'estudiantes', child: Text('Estudiantes')),
                        DropdownMenuItem(value: 'seguridad', child: Text('Seguridad')),
                        DropdownMenuItem(value: 'admin', child: Text('Administracion')),
                        DropdownMenuItem(value: 'facultad', child: Text('Por facultad')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => audiencia = value);
                      },
                    ),
                    if (audiencia == 'facultad') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: facultadCtrl,
                        decoration: const InputDecoration(labelText: 'Facultad objetivo'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Alerta activa'),
                      value: activa,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setDialogState(() => activa = value),
                    ),
                    SwitchListTile(
                      title: const Text('Programada'),
                      value: programada,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setDialogState(() => programada = value),
                    ),
                    if (programada)
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          fechaProgramada != null
                              ? _formatDate(fechaProgramada)
                              : 'Seleccionar fecha y hora',
                        ),
                        onTap: () async {
                          final baseDate = fechaProgramada ?? DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: baseDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate == null || !mounted) return;

                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(baseDate),
                          );
                          if (pickedTime == null) return;

                          setDialogState(() {
                            fechaProgramada = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<AlertaProvider>().editarAlerta(
                          id: alerta.id!,
                          titulo: tituloCtrl.text.trim(),
                          mensaje: mensajeCtrl.text.trim(),
                          programada: programada,
                          fechaProgramada: fechaProgramada,
                          tipo: tipo,
                          audiencia: audiencia,
                          facultadObjetivo: facultadCtrl.text.trim().isEmpty
                              ? null
                              : facultadCtrl.text.trim(),
                          activa: activa,
                        );

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
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

  void _showDeleteDialog(AlertaEntity alerta) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar alerta'),
          content: Text('Eliminar la alerta "${alerta.titulo}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<AlertaProvider>().eliminarAlerta(alerta.id!);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAlertaActions(AlertaEntity alerta) {
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
                Text(
                  alerta.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  alerta.mensaje,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditDialog(alerta);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.dangerColor),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteDialog(alerta);
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
    final alertaProvider = context.watch<AlertaProvider>();

    return Scaffold(
      body: Column(
        children: [
          if (alertaProvider.error != null)
            Container(
              width: double.infinity,
              color: AppTheme.dangerColor.withValues(alpha: 0.08),
              padding: const EdgeInsets.all(12),
              child: Text(
                alertaProvider.error!,
                style: const TextStyle(color: AppTheme.dangerColor),
              ),
            ),
          Expanded(
            child: alertaProvider.loading && alertaProvider.alertas.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : alertaProvider.alertas.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay alertas',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => alertaProvider.cargarAlertas(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: alertaProvider.alertas.length,
                          itemBuilder: (_, index) {
                            final alerta = alertaProvider.alertas[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: alerta.programada
                                      ? AppTheme.warningColor
                                      : AppTheme.primaryColor,
                                  child: Icon(
                                    alerta.programada ? Icons.schedule : Icons.campaign,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  alerta.titulo,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alerta.mensaje,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatDate(alerta.fecha ?? alerta.fechaProgramada),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _MiniChip(label: alerta.tipo),
                                        _MiniChip(label: alerta.audiencia),
                                        _MiniChip(label: alerta.activa ? 'activa' : 'inactiva'),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => _showAlertaActions(alerta),
                                onLongPress: () => _showAlertaActions(alerta),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: alertaProvider.loading ? null : _showCreateDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;

  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
