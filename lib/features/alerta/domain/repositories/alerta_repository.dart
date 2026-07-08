import '../entities/alerta.dart';

abstract class AlertaRepository {
  Future<List<AlertaEntity>> getAlertas();
  Future<AlertaEntity> crearAlerta({
    required String titulo,
    required String mensaje,
    required String creadorId,
    bool? programada,
    DateTime? fechaProgramada,
  });
  Future<AlertaEntity> editarAlerta({
    required String id,
    required String titulo,
    required String mensaje,
    bool? programada,
    DateTime? fechaProgramada,
  });
  Future<void> eliminarAlerta(String id);
}
