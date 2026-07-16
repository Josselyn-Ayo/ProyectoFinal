import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../alerta/domain/entities/alerta.dart';
import '../../../alerta/presentation/providers/alerta_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../incidente/presentation/pages/mapa_page.dart';
import '../../../incidente/presentation/pages/mis_reportes_page.dart';
import '../../../incidente/presentation/pages/reportar_incidente_page.dart';
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
        title: const Text('CampusSOS EPN'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined, size: 32),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilPage()),
                );
                return;
              }
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Estás seguro de que deseas salir?'),
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
              if (confirmar == true) await auth.logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Mi perfil')),
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(auth),
                    const SizedBox(height: 20),
                    _buildSosButton(),
                    const SizedBox(height: 24),
                    _buildUltimasAlertas(alerta),
                    const SizedBox(height: 24),
                    _buildAccesosRapidos(constraints.maxWidth),
                    const SizedBox(height: 24),
                    if (constraints.maxWidth >= 600)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildEstadoReportes(incidente)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CentroSeguridadCard(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CentroSeguridadPage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildEstadoReportes(incidente),
                      const SizedBox(height: 12),
                      _buildCentroSeguridadCallout(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        indicatorColor: AppTheme.softTeal,
        onDestinationSelected: _openBottomDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _openBottomDestination(int index) {
    final List<Widget?> pages = [
      null,
      const MapaIncidentePage(),
      const MisReportesPage(),
      const AlertasEstudiantePage(),
      const PerfilPage(),
    ];
    final page = pages[index];
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  Widget _buildWelcomeHeader(AuthProvider auth) {
    final nombre = auth.user?.nombre ?? 'Usuario';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $nombre',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.inkColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Campus protegido, comunidad segura.',
                style: TextStyle(fontSize: 15, color: AppTheme.mutedColor),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.softBlue,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppTheme.outlineColor),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppTheme.secondaryColor,
                size: 19,
              ),
              SizedBox(width: 6),
              Text(
                'Seguro',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSosButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final uid = auth.userId ?? '';

        return Center(
          child: SizedBox(
            width: 202,
            height: 202,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SosPage(usuarioId: uid)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 8,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos, size: 62),
                  SizedBox(height: 4),
                  Text(
                    'SOS',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ayuda inmediata',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
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

  Widget _buildAccesosRapidos(double availableWidth) {
    final accesos = [
      _AccesoRapido(
        icon: Icons.report_problem,
        label: 'Reportar',
        color: AppTheme.dangerColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportarIncidentePage()),
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
            MaterialPageRoute(builder: (_) => const AlertasEstudiantePage()),
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
          crossAxisCount: availableWidth >= 600 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: availableWidth >= 600 ? 1.15 : 1.45,
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: acceso.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              acceso.icon,
                              size: 28,
                              color: acceso.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            acceso.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incidente.loading
                        ? 'Cargando...'
                        : '$activos reportes activos',
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
    return _CentroSeguridadCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CentroSeguridadPage()),
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
      final facultadObjetivo = alerta.facultadObjetivo
          ?.toString()
          .trim()
          .toLowerCase();
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

class _CentroSeguridadCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _CentroSeguridadCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Centro de Seguridad',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Protocolos, contactos y recomendaciones para el campus.',
                style: TextStyle(color: AppTheme.mutedColor, height: 1.35),
              ),
              if (onTap != null) ...[
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      'Consultar guia',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
