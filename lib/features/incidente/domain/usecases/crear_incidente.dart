import '../../../../core/usecases/usecase.dart';
import '../entities/incidente.dart';
import '../repositories/incidente_repository.dart';

class CrearIncidenteParams {
  final String? usuarioId;
  final String tipo;
  final String? descripcion;
  final double? latitud;
  final double? longitud;
  final String? foto;
  final String? prioridad;
  final bool anonimo;
  final String? ubicacionReferencia;

  const CrearIncidenteParams({
    this.usuarioId,
    required this.tipo,
    this.descripcion,
    this.latitud,
    this.longitud,
    this.foto,
    this.prioridad,
    this.anonimo = false,
    this.ubicacionReferencia,
  });
}

class CrearIncidenteUseCase implements UseCase<IncidenteEntity, CrearIncidenteParams> {
  final IncidenteRepository repository;

  CrearIncidenteUseCase(this.repository);

  @override
  Future<IncidenteEntity> call(CrearIncidenteParams params) async {
    return repository.crearIncidente(
      usuarioId: params.usuarioId,
      tipo: params.tipo,
      descripcion: params.descripcion,
      latitud: params.latitud,
      longitud: params.longitud,
      foto: params.foto,
      prioridad: params.prioridad,
      anonimo: params.anonimo,
      ubicacionReferencia: params.ubicacionReferencia,
    );
  }
}
