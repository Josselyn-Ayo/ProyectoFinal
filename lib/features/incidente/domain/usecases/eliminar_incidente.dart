import '../../../../core/usecases/usecase.dart';
import '../repositories/incidente_repository.dart';

class EliminarIncidenteUseCase implements UseCase<void, String> {
  final IncidenteRepository repository;

  EliminarIncidenteUseCase(this.repository);

  @override
  Future<void> call(String incidenteId) async {
    await repository.eliminarIncidente(incidenteId);
  }
}
