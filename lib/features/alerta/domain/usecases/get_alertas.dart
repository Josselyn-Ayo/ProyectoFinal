import '../../../../../core/usecases/usecase.dart';
import '../repositories/alerta_repository.dart';
import '../entities/alerta.dart';

class GetAlertasUseCase extends UseCase<List<AlertaEntity>, NoParams> {
  final AlertaRepository repository;
  GetAlertasUseCase(this.repository);

  @override
  Future<List<AlertaEntity>> call(NoParams params) async {
    return await repository.getAlertas();
  }
}
