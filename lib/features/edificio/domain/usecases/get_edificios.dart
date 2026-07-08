import '../../../../../core/usecases/usecase.dart';
import '../repositories/edificio_repository.dart';
import '../entities/edificio.dart';

class GetEdificiosUseCase extends UseCase<List<EdificioEntity>, NoParams> {
  final EdificioRepository repository;
  GetEdificiosUseCase(this.repository);

  @override
  Future<List<EdificioEntity>> call(NoParams params) async {
    return await repository.getEdificios();
  }
}
