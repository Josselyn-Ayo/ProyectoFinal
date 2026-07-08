import '../../../../../core/usecases/usecase.dart';
import '../repositories/guardia_repository.dart';
import '../entities/guardia.dart';

class RegistrarGuardiaParams {
  final String usuarioId;
  final String? turno;
  final String? estado;

  RegistrarGuardiaParams({
    required this.usuarioId,
    this.turno,
    this.estado,
  });
}

class RegistrarGuardiaUseCase extends UseCase<GuardiaEntity, RegistrarGuardiaParams> {
  final GuardiaRepository repository;
  RegistrarGuardiaUseCase(this.repository);

  @override
  Future<GuardiaEntity> call(RegistrarGuardiaParams params) async {
    return await repository.registrarGuardia(
      usuarioId: params.usuarioId,
      turno: params.turno,
      estado: params.estado,
    );
  }
}
