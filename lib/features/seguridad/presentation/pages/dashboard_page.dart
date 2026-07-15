import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../../../../core/widgets/campus_map_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../edificio/presentation/providers/edificio_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import 'emergencias_page.dart';
import 'historial_page.dart';
import 'mapa_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardTab(),
    EmergenciasPage(),
    MapaSeguridadPage(),
    HistorialPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final incidenteProvider = context.read<IncidenteProvider>();
    final guardiaProvider = context.read<GuardiaProvider>();
    final authProvider = context.read<AuthProvider>();
    final edificioProvider = context.read<EdificioProvider>();

    await Future.wait([
      incidenteProvider.cargarTodosIncidentes(),
      incidenteProvider.cargarIncidentesActivos(),
      guardiaProvider.cargarGuardias(),
      edificioProvider.cargarEdificios(),
    ]);

    if (authProvider.userId != null) {
      await guardiaProvider.cargarMiGuardia(authProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.user?.nombreCompleto ?? 'Seguridad'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 30),
            onSelected: (value) {
              if (value == 'logout') {
                auth.logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Emergencias'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();
    final guardiaProvider = context.watch<GuardiaProvider>();
    final edificioProvider = context.watch<EdificioProvider>();

    final emergenciasActivas = incidenteProvider.emergenciasActivas;
    final incidentesHoy = incidenteProvider.todosIncidentes.where((incidente) {
      final fecha = incidente.fecha;
      if (fecha == null) return false;
      final hoy = DateTime.now();
      return fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day;
    }).length;
    final casosAsignados = incidenteProvider.todosIncidentes
        .where(
          (incidente) =>
              incidente.guardiaId == guardiaProvider.miGuardia?.id &&
              incidente.estado.toLowerCase() != 'cerrado',
        )
        .length;
    final guardiasDisponibles =
        guardiaProvider.guardias.where((guardia) => guardia.disponible).length;
    final incidentesConUbicacion = incidenteProvider.incidentesActivos
        .where((incidente) => incidente.latitud != null && incidente.longitud != null)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          incidenteProvider.cargarTodosIncidentes(),
          incidenteProvider.cargarIncidentesActivos(),
          guardiaProvider.cargarGuardias(),
          edificioProvider.cargarEdificios(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _SummaryCard(
                title: 'Emergencias\nActivas',
                value: emergenciasActivas.toString(),
                color: AppTheme.dangerColor,
                icon: Icons.warning_amber_rounded,
              ),
              _SummaryCard(
                title: 'Incidentes\ndel Dia',
                value: incidentesHoy.toString(),
                color: AppTheme.primaryColor,
                icon: Icons.receipt_long,
              ),
              _SummaryCard(
                title: 'Casos\nAsignados',
                value: casosAsignados.toString(),
                color: AppTheme.warningColor,
                icon: Icons.assignment_ind,
              ),
              _SummaryCard(
                title: 'Guardias\nDisponibles',
                value: guardiasDisponibles.toString(),
                color: AppTheme.successColor,
                icon: Icons.shield,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                CampusMapWidget(
                  incidentes: incidentesConUbicacion,
                  edificios: edificioProvider.edificios,
                  initialZoom: 15.5,
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      incidentesConUbicacion.isEmpty
                          ? 'No hay incidentes activos con ubicacion en este momento.'
                          : '${incidentesConUbicacion.length} incidentes visibles en el mapa del campus.',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
