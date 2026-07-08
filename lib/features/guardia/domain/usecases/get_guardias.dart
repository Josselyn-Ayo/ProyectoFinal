import '../../../../../core/usecases/usecase.dart';
import '../repositories/guardia_repository.dart';
import '../entities/guardia.dart';

class GetGuardiasUseCase extends UseCase<List<GuardiaEntity>, NoParams> {
  final GuardiaRepository repository;
  GetGuardiasUseCase(this.repository);

  @override
  Future<List<GuardiaEntity>> call(NoParams params) async {
    return await repository.getGuardias();
  }
}
