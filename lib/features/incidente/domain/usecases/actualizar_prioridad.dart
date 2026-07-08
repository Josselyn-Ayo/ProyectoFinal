import '../../../../core/usecases/usecase.dart';
import '../repositories/incidente_repository.dart';

class ActualizarPrioridadParams {
  final String incidenteId;
  final String prioridad;

  const ActualizarPrioridadParams({
    required this.incidenteId,
    required this.prioridad,
  });
}

class ActualizarPrioridadUseCase
    implements UseCase<void, ActualizarPrioridadParams> {
  final IncidenteRepository repository;

  ActualizarPrioridadUseCase(this.repository);

  @override
  Future<void> call(ActualizarPrioridadParams params) async {
    await repository.actualizarPrioridad(params.incidenteId, params.prioridad);
  }
}
