import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../alerta/domain/entities/alerta.dart';
import '../../../alerta/presentation/providers/alerta_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../incidente/presentation/pages/mapa_page.dart';
import '../../../incidente/presentation/pages/mis_reportes_page.dart';
import '../../../incidente/presentation/pages/sos_page.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import 'alertas_estudiante_page.dart';
import 'centro_seguridad_page.dart';
import 'perfil_page.dart';

class EstudianteHomePage extends StatefulWidget {
  const EstudianteHomePage({super.key});

  @override
  State<EstudianteHomePage> createState() => _EstudianteHomePageState();
}

class _EstudianteHomePageState extends State<EstudianteHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertaProvider>().cargarAlertas();
      context.read<IncidenteProvider>().cargarIncidentesActivos();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<AlertaProvider>().cargarAlertas(),
      context.read<IncidenteProvider>().cargarIncidentesActivos(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final alerta = context.watch<AlertaProvider>();
    final incidente = context.watch<IncidenteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad Universitaria'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesion'),
                  content: const Text('Estas seguro de que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );

              if (confirmar == true) {
                await auth.logout();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(auth),
              const SizedBox(height: 24),
              _buildSosButton(),
              const SizedBox(height: 24),
              _buildUltimasAlertas(alerta),
              const SizedBox(height: 24),
              _buildAccesosRapidos(),
              const SizedBox(height: 24),
              _buildEstadoReportes(incidente),
              const SizedBox(height: 24),
              _buildCentroSeguridadCallout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider auth) {
    final nombre = auth.user?.nombre ?? 'Usuario';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido/a',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final uid = auth.userId ?? '';

        return SizedBox(
          width: double.infinity,
          height: 100,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SosPage(usuarioId: uid)),
              );
            },
            icon: const Icon(Icons.warning_amber_rounded, size: 40),
            label: const Text(
              'SOS',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltimasAlertas(AlertaProvider alerta) {
    final user = context.read<AuthProvider>().user;
    final alertas = alerta.alertas
        .where((item) => _shouldShowAlert(item, user))
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ultimas Alertas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AlertasEstudiantePage(),
                  ),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (alerta.loading && alertas.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (alertas.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No hay alertas activas',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ...alertas.map(
            (item) => Card(
              child: ListTile(
                leading: Icon(
                  _alertIcon(item.tipo),
                  color: _alertColor(item.tipo),
                ),
                title: Text(item.titulo),
                subtitle: Text(item.mensaje),
                trailing: item.fecha != null
                    ? Text(
                        _formatDate(item.fecha!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccesosRapidos() {
    final accesos = [
      _AccesoRapido(
        icon: Icons.report_problem,
        label: 'Reportar',
        color: AppTheme.dangerColor,
        onTap: () {
          final uid = context.read<AuthProvider>().userId ?? '';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SosPage(usuarioId: uid)),
          );
        },
      ),
      _AccesoRapido(
        icon: Icons.map,
        label: 'Mapa',
        color: AppTheme.successColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapaIncidentePage()),
          );
        },
      ),
      _AccesoRapido(
        icon: Icons.notifications_active,
        label: 'Alertas',
        color: AppTheme.warningColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AlertasEstudiantePage(),
            ),
          );
        },
      ),
      _AccesoRapido(
        icon: Icons.assignment,
        label: 'Mis Reportes',
        color: AppTheme.secondaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MisReportesPage()),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos Rapidos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: accesos
              .map(
                (acceso) => Card(
                  child: InkWell(
                    onTap: acceso.onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(acceso.icon, size: 36, color: acceso.color),
                          const SizedBox(height: 8),
                          Text(
                            acceso.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEstadoReportes(IncidenteProvider incidente) {
    final activos = incidente.emergenciasActivas;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.analytics,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado de Reportes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incidente.loading ? 'Cargando...' : '$activos reportes activos',
                    style: TextStyle(
                      fontSize: 14,
                      color: activos > 0
                          ? AppTheme.dangerColor
                          : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentroSeguridadCallout() {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shield_moon, color: AppTheme.warningColor),
        ),
        title: const Text(
          'Centro de Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Contactos, protocolo de emergencia y recomendaciones para el campus.',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CentroSeguridadPage()),
          );
        },
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

    final audiencia = alerta.audiencia;
    if (audiencia == 'todos') return true;
    if (audiencia == 'estudiantes') return true;
    if (audiencia == 'facultad') {
      final facultadUsuario = user?.facultad?.toString().trim().toLowerCase();
      final facultadObjetivo =
          alerta.facultadObjetivo?.toString().trim().toLowerCase();
      return facultadUsuario != null &&
          facultadUsuario.isNotEmpty &&
          facultadObjetivo != null &&
          facultadObjetivo.isNotEmpty &&
          facultadUsuario == facultadObjetivo;
    }
    return false;
  }

  IconData _alertIcon(String tipo) {
    switch (tipo) {
      case 'urgente':
        return Icons.warning_amber_rounded;
      case 'preventiva':
        return Icons.shield_outlined;
      case 'simulacro':
        return Icons.notifications_active_outlined;
      default:
        return Icons.campaign;
    }
  }

  Color _alertColor(String tipo) {
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
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AccesoRapido {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
