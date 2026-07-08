import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/incidente_provider.dart';

class MisReportesPage extends StatefulWidget {
  const MisReportesPage({super.key});

  @override
  State<MisReportesPage> createState() => _MisReportesPageState();
}

class _MisReportesPageState extends State<MisReportesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<IncidenteProvider>().cargarMisIncidentes(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reportes')),
      body: incidenteProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : incidenteProvider.misIncidentes.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.assignment, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No tienes reportes',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final userId = context.read<AuthProvider>().userId;
                    if (userId != null) {
                      await context
                          .read<IncidenteProvider>()
                          .cargarMisIncidentes(userId);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: incidenteProvider.misIncidentes.length,
                    itemBuilder: (context, index) {
                      final incidente =
                          incidenteProvider.misIncidentes[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.warning,
                            color: incidente.estado == 'cerrado'
                                ? AppTheme.successColor
                                : AppTheme.dangerColor,
                          ),
                          title: Text(incidente.tipo),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (incidente.descripcion != null)
                                Text(incidente.descripcion!,
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Estado: ${incidente.estadoFormateado}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: incidente.fecha != null
                              ? Text(
                                  '${incidente.fecha!.day}/${incidente.fecha!.month}/${incidente.fecha!.year}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
