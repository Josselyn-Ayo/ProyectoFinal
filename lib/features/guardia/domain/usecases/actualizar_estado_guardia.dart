import '../../../../../core/usecases/usecase.dart';
import '../repositories/guardia_repository.dart';
import '../entities/guardia.dart';

class ActualizarEstadoGuardiaParams {
  final String guardiaId;
  final String estado;

  ActualizarEstadoGuardiaParams({
    required this.guardiaId,
    required this.estado,
  });
}

class ActualizarEstadoGuardiaUseCase extends UseCase<GuardiaEntity, ActualizarEstadoGuardiaParams> {
  final GuardiaRepository repository;
  ActualizarEstadoGuardiaUseCase(this.repository);

  @override
  Future<GuardiaEntity> call(ActualizarEstadoGuardiaParams params) async {
    return await repository.actualizarEstadoGuardia(
      guardiaId: params.guardiaId,
      estado: params.estado,
    );
  }
}
