import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final Duration duration;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.duration,
  });
}

class RoutingService {
  static const _baseUrl = 'https://router.project-osrm.org';

  Future<RouteResult> obtenerRuta({
    required LatLng origen,
    required LatLng destino,
  }) async {
    final coordinates =
        '${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}';
    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/$coordinates?overview=full&geometries=geojson',
    );
    final client = HttpClient();

    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 12));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final body = await utf8.decoder.bind(response).join();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode != HttpStatus.ok || data['code'] != 'Ok') {
        throw StateError(data['message'] ?? 'No fue posible calcular la ruta');
      }

      final route = (data['routes'] as List).first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;

      return RouteResult(
        points: coordinates.map((item) {
          final point = item as List;
          return LatLng(
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          );
        }).toList(),
        distanceMeters: (route['distance'] as num).toDouble(),
        duration: Duration(seconds: (route['duration'] as num).round()),
      );
    } on SocketException {
      throw StateError('Sin conexion para consultar la ruta');
    } finally {
      client.close(force: true);
    }
  }
}
