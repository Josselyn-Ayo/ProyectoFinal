import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../alerta/presentation/providers/alerta_provider.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../incidente/presentation/pages/sos_page.dart';
import 'perfil_page.dart';
import 'alertas_estudiante_page.dart';

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilPage()),
              );
            },
            tooltip: 'Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
              if (confirmar == true) {
                await auth.logout();
              }
            },
            tooltip: 'Cerrar sesión',
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
                MaterialPageRoute(
                    builder: (_) => SosPage(usuarioId: uid)),
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
    final alertas = alerta.alertas.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Últimas Alertas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AlertasEstudiantePage()),
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
          ...alertas.map((a) => Card(
                child: ListTile(
                  leading: const Icon(Icons.campaign,
                      color: AppTheme.warningColor),
                  title: Text(a.titulo),
                  subtitle: Text(a.mensaje),
                  trailing: a.fecha != null
                      ? Text(
                          _formatDate(a.fecha!),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : null,
                ),
              )),
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
            MaterialPageRoute(
                builder: (_) => SosPage(usuarioId: uid)),
          );
        },
      ),
      _AccesoRapido(
        icon: Icons.map,
        label: 'Mapa',
        color: AppTheme.successColor,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mapa en construcción')),
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
                builder: (_) => const AlertasEstudiantePage()),
          );
        },
      ),
      _AccesoRapido(
        icon: Icons.assignment,
        label: 'Mis Reportes',
        color: AppTheme.secondaryColor,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mis Reportes en construcción')),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos Rápidos',
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
              .map((a) => Card(
                    child: InkWell(
                      onTap: a.onTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(a.icon, size: 36, color: a.color),
                            const SizedBox(height: 8),
                            Text(
                              a.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
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
