import '../../../../../core/usecases/usecase.dart';
import '../repositories/alerta_repository.dart';
import '../entities/alerta.dart';

class EditarAlertaParams {
  final String id;
  final String titulo;
  final String mensaje;
  final bool? programada;
  final DateTime? fechaProgramada;

  EditarAlertaParams({
    required this.id,
    required this.titulo,
    required this.mensaje,
    this.programada,
    this.fechaProgramada,
  });
}

class EditarAlertaUseCase extends UseCase<AlertaEntity, EditarAlertaParams> {
  final AlertaRepository repository;
  EditarAlertaUseCase(this.repository);

  @override
  Future<AlertaEntity> call(EditarAlertaParams params) async {
    return await repository.editarAlerta(
      id: params.id,
      titulo: params.titulo,
      mensaje: params.mensaje,
      programada: params.programada,
      fechaProgramada: params.fechaProgramada,
    );
  }
}
