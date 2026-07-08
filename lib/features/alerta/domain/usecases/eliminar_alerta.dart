import '../../../../../core/usecases/usecase.dart';
import '../repositories/alerta_repository.dart';

class EliminarAlertaParams {
  final String id;
  EliminarAlertaParams({required this.id});
}

class EliminarAlertaUseCase extends UseCase<void, EliminarAlertaParams> {
  final AlertaRepository repository;
  EliminarAlertaUseCase(this.repository);

  @override
  Future<void> call(EliminarAlertaParams params) async {
    return await repository.eliminarAlerta(params.id);
  }
}
