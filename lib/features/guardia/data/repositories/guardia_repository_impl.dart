import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/guardia.dart';
import '../../domain/repositories/guardia_repository.dart';
import '../datasources/guardia_remote_datasource.dart';
import '../models/guardia_model.dart';

class GuardiaRepositoryImpl implements GuardiaRepository {
  final GuardiaRemoteDataSource remoteDataSource;

  GuardiaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GuardiaEntity>> getGuardias() async {
    try {
      return await remoteDataSource.getGuardias();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaEntity?> getGuardiaByUsuarioId(String uid) async {
    try {
      return await remoteDataSource.getGuardiaByUsuarioId(uid);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaEntity> registrarGuardia({
    required String usuarioId,
    String? turno,
    String? estado,
  }) async {
    try {
      final model = GuardiaModel(
        usuarioId: usuarioId,
        turno: turno,
        estado: estado ?? 'Disponible',
      );
      return await remoteDataSource.registrarGuardia(model);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaEntity> editarGuardia({
    required String id,
    String? turno,
    String? estado,
  }) async {
    try {
      final model = GuardiaModel(
        usuarioId: '',
        turno: turno,
        estado: estado ?? 'Disponible',
      );
      return await remoteDataSource.editarGuardia(id, model);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarGuardia(String id) async {
    try {
      await remoteDataSource.eliminarGuardia(id);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaEntity> actualizarEstadoGuardia({
    required String guardiaId,
    required String estado,
  }) async {
    try {
      return await remoteDataSource.actualizarEstadoGuardia(guardiaId, estado);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}
