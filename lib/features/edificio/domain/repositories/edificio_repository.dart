import '../entities/edificio.dart';

abstract class EdificioRepository {
  Future<List<EdificioEntity>> getEdificios();
  Future<EdificioEntity> crearEdificio({
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  });
  Future<EdificioEntity> editarEdificio({
    required String id,
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  });
  Future<void> eliminarEdificio(String id);
}
