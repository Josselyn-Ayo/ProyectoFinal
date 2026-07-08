import '../../../../core/usecases/usecase.dart';
import '../repositories/incidente_repository.dart';

class ActualizarEstadoParams {
  final String incidenteId;
  final String estado;
  final String? guardiaId;
  final String? respuesta;

  const ActualizarEstadoParams({
    required this.incidenteId,
    required this.estado,
    this.guardiaId,
    this.respuesta,
  });
}

class ActualizarEstadoUseCase
    implements UseCase<void, ActualizarEstadoParams> {
  final IncidenteRepository repository;

  ActualizarEstadoUseCase(this.repository);

  @override
  Future<void> call(ActualizarEstadoParams params) async {
    await repository.actualizarEstado(
      incidenteId: params.incidenteId,
      estado: params.estado,
      guardiaId: params.guardiaId,
      respuesta: params.respuesta,
    );
  }
}
