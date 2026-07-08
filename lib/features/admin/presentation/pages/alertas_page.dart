import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  void _showCreateDialog() {
    final tituloCtrl = TextEditingController();
    final mensajeCtrl = TextEditingController();
    bool programada = false;
    DateTime? fechaProgramada;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Alerta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: mensajeCtrl,
                      decoration: const InputDecoration(labelText: 'Mensaje'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Programada'),
                      value: programada,
                      onChanged: (v) =>
                          setDialogState(() => programada = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (programada)
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(fechaProgramada != null
                            ? _formatDate(fechaProgramada)
                            : 'Seleccionar fecha'),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(
                                () => fechaProgramada = picked);
                          }
                        },
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
                    final auth = context.read<AuthProvider>();
                    context.read<AlertaProvider>().crearAlerta(
                          titulo: tituloCtrl.text.trim(),
                          mensaje: mensajeCtrl.text.trim(),
                          creadorId: auth.userId ?? '',
                          programada: programada,
                          fechaProgramada: fechaProgramada,
                        );
                    Navigator.pop(ctx);
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

  void _showEditDialog(AlertaEntity alerta) {
    final tituloCtrl = TextEditingController(text: alerta.titulo);
    final mensajeCtrl = TextEditingController(text: alerta.mensaje);
    bool programada = alerta.programada;
    DateTime? fechaProgramada = alerta.fechaProgramada;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Alerta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: mensajeCtrl,
                      decoration: const InputDecoration(labelText: 'Mensaje'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Programada'),
                      value: programada,
                      onChanged: (v) =>
                          setDialogState(() => programada = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (programada)
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(fechaProgramada != null
                            ? _formatDate(fechaProgramada)
                            : 'Seleccionar fecha'),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fechaProgramada ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(
                                () => fechaProgramada = picked);
                          }
                        },
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
                    context.read<AlertaProvider>().editarAlerta(
                          id: alerta.id!,
                          titulo: tituloCtrl.text.trim(),
                          mensaje: mensajeCtrl.text.trim(),
                          programada: programada,
                          fechaProgramada: fechaProgramada,
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

  void _showDeleteDialog(AlertaEntity alerta) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar Alerta'),
          content: Text('¿Eliminar la alerta "${alerta.titulo}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                context
                    .read<AlertaProvider>()
                    .eliminarAlerta(alerta.id!);
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
                Text(alerta.titulo,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(alerta.mensaje,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
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
                  leading:
                      const Icon(Icons.delete, color: AppTheme.dangerColor),
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

    if (alertaProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (alertaProvider.alertas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay alertas',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: alertaProvider.alertas.length,
        itemBuilder: (_, i) {
          final alerta = alertaProvider.alertas[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: alerta.programada
                    ? AppTheme.warningColor
                    : AppTheme.primaryColor,
                child: Icon(
                    alerta.programada ? Icons.schedule : Icons.campaign,
                    color: Colors.white),
              ),
              title: Text(alerta.titulo,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alerta.mensaje,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(_formatDate(alerta.fecha),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              onTap: () => _showAlertaActions(alerta),
              onLongPress: () => _showAlertaActions(alerta),
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
