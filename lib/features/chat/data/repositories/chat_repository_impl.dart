import '../../domain/entities/mensaje.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MensajeEntity>> getMensajes(String incidenteId) async {
    final models = await remoteDataSource.getMensajes(incidenteId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> enviarMensaje(
      String incidenteId, String emisorId, String mensaje) async {
    await remoteDataSource.enviarMensaje(
      incidenteId: incidenteId,
      emisorId: emisorId,
      mensaje: mensaje,
    );
  }

  @override
  Stream<List<MensajeEntity>> streamMensajes(String incidenteId) {
    return remoteDataSource
        .streamMensajes(incidenteId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
