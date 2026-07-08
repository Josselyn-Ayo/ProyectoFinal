import '../entities/guardia.dart';

abstract class GuardiaRepository {
  Future<List<GuardiaEntity>> getGuardias();
  Future<GuardiaEntity?> getGuardiaByUsuarioId(String uid);
  Future<GuardiaEntity> registrarGuardia({
    required String usuarioId,
    String? turno,
    String? estado,
  });
  Future<GuardiaEntity> editarGuardia({
    required String id,
    String? turno,
    String? estado,
  });
  Future<void> eliminarGuardia(String id);
  Future<GuardiaEntity> actualizarEstadoGuardia({
    required String guardiaId,
    required String estado,
  });
}
