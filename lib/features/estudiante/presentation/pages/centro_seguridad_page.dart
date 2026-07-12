import 'package:flutter/material.dart';

import '../../../../core/config/theme.dart';

class CentroSeguridadPage extends StatelessWidget {
  const CentroSeguridadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Contactos de emergencia',
            icon: Icons.contact_phone,
            children: const [
              _InfoTile(title: 'Seguridad EPN', subtitle: 'Ext. 1234 / Atencion 24/7'),
              _InfoTile(title: 'Bienestar estudiantil', subtitle: 'Ext. 2210 / Apoyo y acompanamiento'),
              _InfoTile(title: 'Enfermeria', subtitle: 'Ext. 1102 / Emergencias medicas'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Protocolo rapido',
            icon: Icons.rule,
            children: const [
              _InfoTile(title: '1. Reporta con evidencia', subtitle: 'Usa SOS o Reportar para enviar ubicacion y descripcion'),
              _InfoTile(title: '2. Mantente en un punto visible', subtitle: 'Prioriza zonas iluminadas o con flujo de personas'),
              _InfoTile(title: '3. Usa el chat del caso', subtitle: 'Permite a seguridad guiarte hasta que llegue apoyo'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Recomendaciones de campus',
            icon: Icons.shield_outlined,
            children: const [
              _InfoTile(title: 'Salidas nocturnas', subtitle: 'Comparte tu ruta y evita trayectos sin iluminacion'),
              _InfoTile(title: 'Laboratorios y bloques', subtitle: 'Identifica entradas, salidas y puntos seguros cercanos'),
              _InfoTile(title: 'Reportes anonimos', subtitle: 'Utilizalos para acoso, amenazas o hechos sensibles'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.campaign, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta pantalla ayuda a vender la app como una plataforma preventiva, no solo reactiva.',
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
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
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle, size: 18, color: AppTheme.successColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
