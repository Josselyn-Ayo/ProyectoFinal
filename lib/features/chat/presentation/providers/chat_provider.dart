import 'package:flutter/foundation.dart';
import '../../domain/entities/mensaje.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_mensajes.dart';

class ChatProvider extends ChangeNotifier {
  final GetMensajesUseCase _getMensajesUseCase;
  final EnviarMensajeUseCase _enviarMensajeUseCase;
  final ChatRepository _chatRepository;

  List<MensajeEntity> _mensajes = [];
  bool _loading = false;
  String? _error;

  List<MensajeEntity> get mensajes => _mensajes;
  bool get loading => _loading;
  String? get error => _error;

  ChatProvider({
    required GetMensajesUseCase getMensajesUseCase,
    required EnviarMensajeUseCase enviarMensajeUseCase,
    required ChatRepository chatRepository,
  })  : _getMensajesUseCase = getMensajesUseCase,
        _enviarMensajeUseCase = enviarMensajeUseCase,
        _chatRepository = chatRepository;

  Future<void> cargarMensajes(String incidenteId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _mensajes = await _getMensajesUseCase(incidenteId);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> getMensajes(String incidenteId) async {
    await cargarMensajes(incidenteId);
  }

  Future<void> enviarMensaje(
    String incidenteId,
    String emisorId,
    String mensaje,
  ) async {
    await _enviarMensajeUseCase(EnviarMensajeParams(
      incidenteId: incidenteId,
      emisorId: emisorId,
      mensaje: mensaje,
    ));
    await cargarMensajes(incidenteId);
  }

  Stream<List<MensajeEntity>> streamMensajes(String incidenteId) {
    return _chatRepository.streamMensajes(incidenteId).map((mensajes) {
      _mensajes = mensajes;
      _error = null;
      Future.microtask(notifyListeners);
      return mensajes;
    });
  }
}
