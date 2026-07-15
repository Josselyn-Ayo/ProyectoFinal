import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/theme.dart';
import '../providers/incidente_provider.dart';

class SosPage extends StatefulWidget {
  final String usuarioId;

  const SosPage({super.key, required this.usuarioId});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final _ubicacionReferenciaController = TextEditingController();
  final _descripcionController = TextEditingController();

  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = true;
  bool _enviando = false;
  bool _anonimo = false;
  String? _ubicacionError;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  @override
  void dispose() {
    _ubicacionReferenciaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
    setState(() {
      _obteniendoUbicacion = true;
      _ubicacionError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _obteniendoUbicacion = false;
          _ubicacionError = 'GPS desactivado';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _obteniendoUbicacion = false;
          _ubicacionError = 'Permiso de ubicacion no disponible';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
        _obteniendoUbicacion = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _obteniendoUbicacion = false;
        _ubicacionError = 'No se pudo obtener ubicacion';
      });
    }
  }

  Future<void> _activarSos() async {
    if (_enviando) return;

    FocusScope.of(context).unfocus();
    setState(() => _enviando = true);

    final referencia = _ubicacionReferenciaController.text.trim();
    final detalle = _descripcionController.text.trim();
    final ubicacionTexto = _latitud != null && _longitud != null
        ? 'Ubicacion GPS: $_latitud, $_longitud.'
        : 'Ubicacion GPS no disponible. Revisar referencia del usuario.';

    final descripcion = [
      'ALERTA SOS ACTIVADA. El estudiante solicita ayuda inmediata.',
      ubicacionTexto,
      if (referencia.isNotEmpty) 'Referencia: $referencia.',
      if (detalle.isNotEmpty) 'Detalle adicional: $detalle.',
    ].join(' ');

    final provider = context.read<IncidenteProvider>();
    final incidente = await provider.crearIncidente(
      usuarioId: widget.usuarioId,
      tipo: 'sos',
      descripcion: descripcion,
      latitud: _latitud,
      longitud: _longitud,
      prioridad: 'Alta',
      anonimo: _anonimo,
      ubicacionReferencia: referencia.isEmpty ? 'SOS inmediato' : referencia,
    );

    if (!mounted) return;

    setState(() => _enviando = false);

    if (incidente != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.shield, color: AppTheme.successColor),
              SizedBox(width: 8),
              Expanded(child: Text('SOS enviado')),
            ],
          ),
          content: const Text(
            'Seguridad universitaria recibio una alerta critica con tu ubicacion. Mantente en un lugar seguro si puedes.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'No se pudo enviar el SOS'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitud != null && _longitud != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
        backgroundColor: AppTheme.dangerColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.dangerColor.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency_share,
                    color: AppTheme.dangerColor,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alerta de emergencia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasLocation
                        ? 'Tu ubicacion esta lista para enviarse a seguridad.'
                        : 'Puedes activar SOS ahora. Si el GPS no esta listo, se enviara la alerta y tu referencia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LocationStatus(
              loading: _obteniendoUbicacion,
              latitude: _latitud,
              longitude: _longitud,
              error: _ubicacionError,
              onRetry: _obtenerUbicacion,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ubicacionReferenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia rapida opcional',
                hintText: 'Ej. Biblioteca, FIEE, entrada principal',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Detalle opcional',
                hintText: 'Ej. me siguen, accidente, necesito ayuda medica',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _anonimo,
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _anonimo = value),
              contentPadding: EdgeInsets.zero,
              title: const Text('Enviar como anonimo'),
              subtitle: const Text('Seguridad recibira la alerta del caso.'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 68,
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : _activarSos,
                icon: _enviando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.sos, size: 34),
                label: Text(
                  _enviando ? 'ENVIANDO SOS...' : 'ACTIVAR SOS AHORA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dangerColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Se creara un incidente critico de prioridad alta para el equipo de seguridad.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationStatus extends StatelessWidget {
  final bool loading;
  final double? latitude;
  final double? longitude;
  final String? error;
  final VoidCallback onRetry;

  const _LocationStatus({
    required this.loading,
    required this.latitude,
    required this.longitude,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;
    final color = hasLocation
        ? AppTheme.successColor
        : error != null
            ? AppTheme.dangerColor
            : AppTheme.warningColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Icon(
              hasLocation ? Icons.my_location : Icons.location_off,
              color: color,
              size: 30,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loading
                      ? 'Obteniendo ubicacion...'
                      : hasLocation
                          ? 'Ubicacion detectada'
                          : error ?? 'Ubicacion pendiente',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLocation
                      ? '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'
                      : 'El SOS puede enviarse de todas formas.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
          if (!loading && !hasLocation)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reintentar ubicacion',
            ),
        ],
      ),
    );
  }
}
