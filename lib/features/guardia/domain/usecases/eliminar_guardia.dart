import '../../../../../core/usecases/usecase.dart';
import '../repositories/guardia_repository.dart';

class EliminarGuardiaParams {
  final String id;
  EliminarGuardiaParams({required this.id});
}

class EliminarGuardiaUseCase extends UseCase<void, EliminarGuardiaParams> {
  final GuardiaRepository repository;
  EliminarGuardiaUseCase(this.repository);

  @override
  Future<void> call(EliminarGuardiaParams params) async {
    return await repository.eliminarGuardia(params.id);
  }
}
