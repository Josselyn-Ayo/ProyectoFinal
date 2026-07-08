import '../../../../../core/usecases/usecase.dart';
import '../repositories/guardia_repository.dart';
import '../entities/guardia.dart';

class EditarGuardiaParams {
  final String id;
  final String? turno;
  final String? estado;

  EditarGuardiaParams({
    required this.id,
    this.turno,
    this.estado,
  });
}

class EditarGuardiaUseCase extends UseCase<GuardiaEntity, EditarGuardiaParams> {
  final GuardiaRepository repository;
  EditarGuardiaUseCase(this.repository);

  @override
  Future<GuardiaEntity> call(EditarGuardiaParams params) async {
    return await repository.editarGuardia(
      id: params.id,
      turno: params.turno,
      estado: params.estado,
    );
  }
}
