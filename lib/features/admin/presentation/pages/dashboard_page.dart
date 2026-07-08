import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../incidente/presentation/providers/incidente_provider.dart';
import 'usuarios_page.dart';
import 'guardias_page.dart';
import 'incidentes_page.dart';
import 'alertas_page.dart';
import 'edificios_page.dart';
import 'estadisticas_page.dart';
import 'configuracion_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteProvider>().cargarTodosIncidentes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings,
                        size: 36, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    auth.user?.nombreCompleto ?? 'Admin',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    auth.user?.correo ?? '',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.dashboard, 'Inicio', 0),
            _drawerItem(Icons.people, 'Usuarios', 1),
            _drawerItem(Icons.receipt_long, 'Incidentes', 2),
            _drawerItem(Icons.warning, 'Alertas', 3),
            _drawerItem(Icons.shield, 'Guardias', 4),
            _drawerItem(Icons.business, 'Edificios', 5),
            _drawerItem(Icons.bar_chart, 'Estadísticas', 6),
            _drawerItem(Icons.settings, 'Configuración', 7),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          AdminUsuariosPage(),
          AdminIncidentesPage(),
          AdminAlertasPage(),
          AdminGuardiasPage(),
          AdminEdificiosPage(),
          AdminEstadisticasPage(),
          AdminConfiguracionPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Incidentes'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alertas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final selected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon,
          color: selected ? AppTheme.primaryColor : Colors.grey[700]),
      title: Text(title,
          style: TextStyle(
            color: selected ? AppTheme.primaryColor : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          )),
      selected: selected,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final incidenteProvider = context.watch<IncidenteProvider>();

    final totalIncidentes = incidenteProvider.todosIncidentes.length;
    final totalEmergencias = incidenteProvider.emergenciasActivas;
    final totalUsuarios = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _SummaryCard(
                title: 'Usuarios',
                value: totalUsuarios.toString(),
                color: AppTheme.primaryColor,
                icon: Icons.people,
              ),
              _SummaryCard(
                title: 'Incidentes',
                value: totalIncidentes.toString(),
                color: AppTheme.warningColor,
                icon: Icons.receipt_long,
              ),
              _SummaryCard(
                title: 'Emergencias',
                value: totalEmergencias.toString(),
                color: AppTheme.dangerColor,
                icon: Icons.warning_amber,
              ),
              _SummaryCard(
                title: 'Alertas',
                value: '0',
                color: AppTheme.secondaryColor,
                icon: Icons.campaign,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Incidentes por Tipo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Gráfico de Tipos',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Incidentes por Mes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Gráfico de Barras',
                  style: TextStyle(color: Colors.grey)),
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
            Icon(icon, color: Colors.white, size: 30),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            Text(title,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
