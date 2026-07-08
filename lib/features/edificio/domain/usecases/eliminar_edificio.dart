import '../../../../../core/usecases/usecase.dart';
import '../repositories/edificio_repository.dart';

class EliminarEdificioParams {
  final String id;
  EliminarEdificioParams({required this.id});
}

class EliminarEdificioUseCase extends UseCase<void, EliminarEdificioParams> {
  final EdificioRepository repository;
  EliminarEdificioUseCase(this.repository);

  @override
  Future<void> call(EliminarEdificioParams params) async {
    return await repository.eliminarEdificio(params.id);
  }
}
