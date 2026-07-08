import '../../../../core/usecases/usecase.dart';
import '../entities/mensaje.dart';
import '../repositories/chat_repository.dart';

class GetMensajesUseCase implements UseCase<List<MensajeEntity>, String> {
  final ChatRepository repository;

  GetMensajesUseCase(this.repository);

  @override
  Future<List<MensajeEntity>> call(String incidenteId) async {
    return await repository.getMensajes(incidenteId);
  }
}

class EnviarMensajeParams {
  final String incidenteId;
  final String emisorId;
  final String mensaje;

  const EnviarMensajeParams({
    required this.incidenteId,
    required this.emisorId,
    required this.mensaje,
  });
}

class EnviarMensajeUseCase implements UseCase<void, EnviarMensajeParams> {
  final ChatRepository repository;

  EnviarMensajeUseCase(this.repository);

  @override
  Future<void> call(EnviarMensajeParams params) async {
    await repository.enviarMensaje(
      params.incidenteId,
      params.emisorId,
      params.mensaje,
    );
  }
}
