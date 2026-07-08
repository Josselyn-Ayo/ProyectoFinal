import '../../../../core/usecases/usecase.dart';
import '../entities/incidente.dart';
import '../repositories/incidente_repository.dart';

class GetIncidentesUsuarioUseCase
    implements UseCase<List<IncidenteEntity>, String> {
  final IncidenteRepository repository;

  GetIncidentesUsuarioUseCase(this.repository);

  @override
  Future<List<IncidenteEntity>> call(String usuarioId) async {
    return await repository.getIncidentesUsuario(usuarioId);
  }
}

class GetAllIncidentesUseCase
    implements UseCase<List<IncidenteEntity>, NoParams> {
  final IncidenteRepository repository;

  GetAllIncidentesUseCase(this.repository);

  @override
  Future<List<IncidenteEntity>> call(NoParams params) async {
    return await repository.getAllIncidentes();
  }
}

class GetIncidentesActivosUseCase
    implements UseCase<List<IncidenteEntity>, NoParams> {
  final IncidenteRepository repository;

  GetIncidentesActivosUseCase(this.repository);

  @override
  Future<List<IncidenteEntity>> call(NoParams params) async {
    return await repository.getIncidentesActivos();
  }
}
