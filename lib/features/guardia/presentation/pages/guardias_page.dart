import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../guardia/data/datasources/guardia_remote_datasource.dart';
import '../../../guardia/data/repositories/guardia_repository_impl.dart';
import '../../../guardia/domain/usecases/get_guardias.dart';
import '../../../guardia/domain/usecases/get_mi_guardia.dart';
import '../../../guardia/domain/usecases/registrar_guardia.dart';
import '../../../guardia/domain/usecases/editar_guardia.dart';
import '../../../guardia/domain/usecases/eliminar_guardia.dart';
import '../../../guardia/domain/usecases/actualizar_estado_guardia.dart';
import '../providers/guardia_provider.dart';
import '../../domain/entities/guardia.dart';

class GuardiasPage extends StatefulWidget {
  const GuardiasPage({super.key});

  @override
  State<GuardiasPage> createState() => _GuardiasPageState();
}

class _GuardiasPageState extends State<GuardiasPage> {
  late GuardiaProvider _provider;

  @override
  void initState() {
    super.initState();
    final datasource = GuardiaRemoteDataSourceImpl();
    final repository = GuardiaRepositoryImpl(remoteDataSource: datasource);
    _provider = GuardiaProvider(
      getGuardiasUseCase: GetGuardiasUseCase(repository),
      getMiGuardiaUseCase: GetMiGuardiaUseCase(repository),
      registrarGuardiaUseCase: RegistrarGuardiaUseCase(repository),
      editarGuardiaUseCase: EditarGuardiaUseCase(repository),
      eliminarGuardiaUseCase: EliminarGuardiaUseCase(repository),
      actualizarEstadoGuardiaUseCase: ActualizarEstadoGuardiaUseCase(repository),
    );
    _provider.cargarGuardias();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Guardias')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _mostrarDialogoGuardia(context),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Consumer<GuardiaProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.guardias.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.guardias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
                    const SizedBox(height: 16),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.cargarGuardias(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.guardias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay guardias registrados',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.cargarGuardias(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.guardias.length,
                itemBuilder: (context, index) {
                  return _GuardiaCard(
                    guardia: provider.guardias[index],
                    onEdit: (guardia) => _mostrarDialogoGuardia(context, guardia: guardia),
                    onDelete: (id) => _confirmarEliminar(context, id),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogoGuardia(BuildContext context, {GuardiaEntity? guardia}) {
    showDialog(
      context: context,
      builder: (ctx) => _GuardiaFormDialog(
        guardia: guardia,
        provider: _provider,
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar guardia'),
        content: const Text('¿Está seguro de eliminar este guardia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _provider.eliminarGuardia(id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _GuardiaFormDialog extends StatefulWidget {
  final GuardiaEntity? guardia;
  final GuardiaProvider provider;

  const _GuardiaFormDialog({this.guardia, required this.provider});

  @override
  State<_GuardiaFormDialog> createState() => _GuardiaFormDialogState();
}

class _GuardiaFormDialogState extends State<_GuardiaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usuarioIdController;
  late TextEditingController _turnoController;
  String _estado = 'Disponible';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _usuarioIdController = TextEditingController(text: widget.guardia?.usuarioId ?? '');
    _turnoController = TextEditingController(text: widget.guardia?.turno ?? '');
    if (widget.guardia != null) {
      _estado = widget.guardia!.estado;
    }
  }

  @override
  void dispose() {
    _usuarioIdController.dispose();
    _turnoController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.guardia != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar guardia' : 'Registrar guardia'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing)
                TextFormField(
                  controller: _usuarioIdController,
                  decoration: const InputDecoration(labelText: 'ID Usuario'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                ),
              if (!isEditing) const SizedBox(height: 12),
              TextFormField(
                controller: _turnoController,
                decoration: const InputDecoration(labelText: 'Turno'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'Disponible', child: Text('Disponible')),
                  DropdownMenuItem(value: 'Ocupado', child: Text('Ocupado')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _estado = v);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _guardar,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Guardar' : 'Registrar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    if (isEditing) {
      await widget.provider.editarGuardia(
        id: widget.guardia!.id!,
        turno: _turnoController.text.trim().isEmpty ? null : _turnoController.text.trim(),
        estado: _estado,
      );
    } else {
      await widget.provider.registrarGuardia(
        usuarioId: _usuarioIdController.text.trim(),
        turno: _turnoController.text.trim().isEmpty ? null : _turnoController.text.trim(),
        estado: _estado,
      );
    }

    setState(() => _saving = false);

    if (mounted) {
      if (widget.provider.error == null) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.provider.error ?? 'Error al guardar'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }
}

class _GuardiaCard extends StatelessWidget {
  final GuardiaEntity guardia;
  final void Function(GuardiaEntity) onEdit;
  final void Function(String) onDelete;

  const _GuardiaCard({
    required this.guardia,
    required this.onEdit,
    required this.onDelete,
  });

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
                Icon(
                  guardia.disponible ? Icons.check_circle : Icons.cancel,
                  color: guardia.disponible ? AppTheme.successColor : AppTheme.dangerColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guardia.usuarioNombre ?? guardia.usuarioId,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: guardia.disponible
                        ? AppTheme.successColor.withOpacity(0.2)
                        : AppTheme.dangerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    guardia.estado,
                    style: TextStyle(
                      fontSize: 11,
                      color: guardia.disponible ? AppTheme.successColor : AppTheme.dangerColor,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(guardia);
                    } else if (value == 'delete') {
                      onDelete(guardia.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
            if (guardia.usuarioCorreo != null) ...[
              const SizedBox(height: 4),
              Text(
                guardia.usuarioCorreo!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (guardia.turno != null && guardia.turno!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppTheme.secondaryColor),
                  const SizedBox(width: 4),
                  Text('Turno: ${guardia.turno}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
