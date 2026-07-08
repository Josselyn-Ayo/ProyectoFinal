import '../../../../../core/usecases/usecase.dart';
import '../repositories/guardia_repository.dart';
import '../entities/guardia.dart';

class GetMiGuardiaParams {
  final String usuarioId;
  GetMiGuardiaParams({required this.usuarioId});
}

class GetMiGuardiaUseCase extends UseCase<GuardiaEntity?, GetMiGuardiaParams> {
  final GuardiaRepository repository;
  GetMiGuardiaUseCase(this.repository);

  @override
  Future<GuardiaEntity?> call(GetMiGuardiaParams params) async {
    return await repository.getGuardiaByUsuarioId(params.usuarioId);
  }
}
