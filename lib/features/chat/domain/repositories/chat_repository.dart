import '../entities/mensaje.dart';

abstract class ChatRepository {
  Future<List<MensajeEntity>> getMensajes(String incidenteId);

  Future<void> enviarMensaje(String incidenteId, String emisorId, String mensaje);

  Stream<List<MensajeEntity>> streamMensajes(String incidenteId);
}
