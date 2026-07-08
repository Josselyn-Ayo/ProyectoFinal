import '../../../../../core/usecases/usecase.dart';
import '../repositories/alerta_repository.dart';
import '../entities/alerta.dart';

class CrearAlertaParams {
  final String titulo;
  final String mensaje;
  final String creadorId;
  final bool? programada;
  final DateTime? fechaProgramada;

  CrearAlertaParams({
    required this.titulo,
    required this.mensaje,
    required this.creadorId,
    this.programada,
    this.fechaProgramada,
  });
}

class CrearAlertaUseCase extends UseCase<AlertaEntity, CrearAlertaParams> {
  final AlertaRepository repository;
  CrearAlertaUseCase(this.repository);

  @override
  Future<AlertaEntity> call(CrearAlertaParams params) async {
    return await repository.crearAlerta(
      titulo: params.titulo,
      mensaje: params.mensaje,
      creadorId: params.creadorId,
      programada: params.programada,
      fechaProgramada: params.fechaProgramada,
    );
  }
}
