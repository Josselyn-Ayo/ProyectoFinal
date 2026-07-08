import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import '../../../guardia/presentation/providers/guardia_provider.dart';
import 'emergencias_page.dart';
import 'mapa_page.dart';
import 'historial_page.dart';

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
    await incidenteProvider.cargarTodosIncidentes();
    await guardiaProvider.cargarGuardias();
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
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
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

    final emergenciasActivas = incidenteProvider.emergenciasActivas;
    final incidentesHoy = incidenteProvider.todosIncidentes
        .where((i) =>
            i.fecha != null &&
            i.fecha!.day == DateTime.now().day &&
            i.fecha!.month == DateTime.now().month &&
            i.fecha!.year == DateTime.now().year)
        .length;
    final casosAsignados = incidenteProvider.todosIncidentes
        .where((i) => i.guardiaId == guardiaProvider.miGuardia?.id &&
            i.estado != 'Cerrado')
        .length;
    final guardiasDisponibles = guardiaProvider.guardias
        .where((g) => g.disponible)
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        await incidenteProvider.cargarTodosIncidentes();
        await guardiaProvider.cargarGuardias();
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
                title: 'Incidentes\ndel Día',
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
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Mapa de incidentes',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
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
                color: Colors.white70,
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
