import '../entities/incidente.dart';

abstract class IncidenteRepository {
  Future<void> crearIncidente({
    String? usuarioId,
    required String tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    String? foto,
    bool anonimo = false,
    String? ubicacionReferencia,
  });

  Future<List<IncidenteEntity>> getIncidentesUsuario(String usuarioId);

  Future<List<IncidenteEntity>> getAllIncidentes();

  Future<List<IncidenteEntity>> getIncidentesActivos();

  Future<void> actualizarEstado({
    required String incidenteId,
    required String estado,
    String? guardiaId,
    String? respuesta,
  });

  Future<void> actualizarPrioridad(String incidenteId, String prioridad);

  Future<void> eliminarIncidente(String incidenteId);
}
