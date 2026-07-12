import '../../../../../core/usecases/usecase.dart';
import '../repositories/alerta_repository.dart';
import '../entities/alerta.dart';

class CrearAlertaParams {
  final String titulo;
  final String mensaje;
  final String creadorId;
  final bool? programada;
  final DateTime? fechaProgramada;
  final String tipo;
  final String audiencia;
  final String? facultadObjetivo;
  final bool activa;

  CrearAlertaParams({
    required this.titulo,
    required this.mensaje,
    required this.creadorId,
    this.programada,
    this.fechaProgramada,
    this.tipo = 'informativa',
    this.audiencia = 'todos',
    this.facultadObjetivo,
    this.activa = true,
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
      tipo: params.tipo,
      audiencia: params.audiencia,
      facultadObjetivo: params.facultadObjetivo,
      activa: params.activa,
    );
  }
}
