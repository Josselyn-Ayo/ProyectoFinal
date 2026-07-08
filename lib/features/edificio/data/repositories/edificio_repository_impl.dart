import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/edificio.dart';
import '../../domain/repositories/edificio_repository.dart';
import '../datasources/edificio_remote_datasource.dart';
import '../models/edificio_model.dart';

class EdificioRepositoryImpl implements EdificioRepository {
  final EdificioRemoteDataSource remoteDataSource;

  EdificioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<EdificioEntity>> getEdificios() async {
    try {
      return await remoteDataSource.getEdificios();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<EdificioEntity> crearEdificio({
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final model = EdificioModel(
        nombre: nombre,
        descripcion: descripcion,
        latitud: latitud,
        longitud: longitud,
      );
      return await remoteDataSource.crearEdificio(model);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<EdificioEntity> editarEdificio({
    required String id,
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final model = EdificioModel(
        nombre: nombre,
        descripcion: descripcion,
        latitud: latitud,
        longitud: longitud,
      );
      return await remoteDataSource.editarEdificio(id, model);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarEdificio(String id) async {
    try {
      await remoteDataSource.eliminarEdificio(id);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}
