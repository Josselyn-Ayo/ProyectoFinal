import '../../domain/entities/incidente.dart';
import '../../domain/repositories/incidente_repository.dart';
import '../datasources/incidente_remote_datasource.dart';

class IncidenteRepositoryImpl implements IncidenteRepository {
  final IncidenteRemoteDatasource datasource;

  IncidenteRepositoryImpl(this.datasource);

  @override
  Future<IncidenteEntity> crearIncidente({
    String? usuarioId,
    required String tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    String? foto,
    String? prioridad,
    bool anonimo = false,
    String? ubicacionReferencia,
  }) async {
    final model = await datasource.crearIncidente({
      'usuario_id': usuarioId,
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'foto': foto,
      'prioridad': prioridad,
      'anonimo': anonimo,
      'ubicacion_referencia': ubicacionReferencia,
    });
    return model.toEntity();
  }

  @override
  Future<List<IncidenteEntity>> getIncidentesUsuario(String usuarioId) async {
    final models = await datasource.getIncidentesUsuario(usuarioId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<IncidenteEntity>> getAllIncidentes() async {
    final models = await datasource.getAllIncidentes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<IncidenteEntity>> getIncidentesActivos() async {
    final models = await datasource.getIncidentesActivos();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> actualizarEstado({
    required String incidenteId,
    required String estado,
    String? guardiaId,
    String? respuesta,
  }) async {
    await datasource.actualizarEstado(
      incidenteId: incidenteId,
      data: {
        'estado': estado,
        'guardia_id': ?guardiaId,
        'respuesta_seguridad': ?respuesta,
      },
    );
  }

  @override
  Future<void> reclamarIncidente(String incidenteId) {
    return datasource.reclamarIncidente(incidenteId);
  }

  @override
  Future<void> actualizarPrioridad(String incidenteId, String prioridad) async {
    await datasource.actualizarPrioridad(incidenteId, prioridad);
  }

  @override
  Future<void> eliminarIncidente(String incidenteId) async {
    await datasource.eliminarIncidente(incidenteId);
  }
}
