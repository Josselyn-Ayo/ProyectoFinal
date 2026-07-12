import '../../../../core/usecases/usecase.dart';
import '../repositories/incidente_repository.dart';

class CrearIncidenteParams {
  final String? usuarioId;
  final String tipo;
  final String? descripcion;
  final double? latitud;
  final double? longitud;
  final String? foto;
  final bool anonimo;
  final String? ubicacionReferencia;

  const CrearIncidenteParams({
    this.usuarioId,
    required this.tipo,
    this.descripcion,
    this.latitud,
    this.longitud,
    this.foto,
    this.anonimo = false,
    this.ubicacionReferencia,
  });
}

class CrearIncidenteUseCase implements UseCase<void, CrearIncidenteParams> {
  final IncidenteRepository repository;

  CrearIncidenteUseCase(this.repository);

  @override
  Future<void> call(CrearIncidenteParams params) async {
    await repository.crearIncidente(
      usuarioId: params.usuarioId,
      tipo: params.tipo,
      descripcion: params.descripcion,
      latitud: params.latitud,
      longitud: params.longitud,
      foto: params.foto,
      anonimo: params.anonimo,
      ubicacionReferencia: params.ubicacionReferencia,
    );
  }
}
