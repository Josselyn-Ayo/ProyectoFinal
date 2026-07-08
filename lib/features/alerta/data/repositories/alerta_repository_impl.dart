import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/alerta.dart';
import '../../domain/repositories/alerta_repository.dart';
import '../datasources/alerta_remote_datasource.dart';
import '../models/alerta_model.dart';

class AlertaRepositoryImpl implements AlertaRepository {
  final AlertaRemoteDataSource remoteDataSource;

  AlertaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AlertaEntity>> getAlertas() async {
    try {
      return await remoteDataSource.getAlertas();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<AlertaEntity> crearAlerta({
    required String titulo,
    required String mensaje,
    required String creadorId,
    bool? programada,
    DateTime? fechaProgramada,
  }) async {
    try {
      final model = AlertaModel(
        titulo: titulo,
        mensaje: mensaje,
        creadorId: creadorId,
        programada: programada ?? false,
        fechaProgramada: fechaProgramada,
        fecha: DateTime.now(),
      );
      return await remoteDataSource.crearAlerta(model);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<AlertaEntity> editarAlerta({
    required String id,
    required String titulo,
    required String mensaje,
    bool? programada,
    DateTime? fechaProgramada,
  }) async {
    try {
      final model = AlertaModel(
        titulo: titulo,
        mensaje: mensaje,
        programada: programada ?? false,
        fechaProgramada: fechaProgramada,
      );
      return await remoteDataSource.editarAlerta(id, model);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarAlerta(String id) async {
    try {
      await remoteDataSource.eliminarAlerta(id);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}
