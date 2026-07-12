import '../entities/alerta.dart';

abstract class AlertaRepository {
  Future<List<AlertaEntity>> getAlertas();
  Future<AlertaEntity> crearAlerta({
    required String titulo,
    required String mensaje,
    required String creadorId,
    bool? programada,
    DateTime? fechaProgramada,
    String tipo = 'informativa',
    String audiencia = 'todos',
    String? facultadObjetivo,
    bool activa = true,
  });
  Future<AlertaEntity> editarAlerta({
    required String id,
    required String titulo,
    required String mensaje,
    bool? programada,
    DateTime? fechaProgramada,
    String tipo = 'informativa',
    String audiencia = 'todos',
    String? facultadObjetivo,
    bool activa = true,
  });
  Future<void> eliminarAlerta(String id);
}
