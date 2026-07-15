import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mensaje_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient client;

  ChatRemoteDataSource({required this.client});

  Future<List<MensajeModel>> getMensajes(String incidenteId) async {
    final response = await client
        .from('mensajes')
        .select()
        .eq('incidente_id', incidenteId)
        .order('fecha', ascending: true);

    final mensajes = (response as List)
        .map((json) => MensajeModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return _agregarNombresEmisores(mensajes);
  }

  Future<void> enviarMensaje({
    required String incidenteId,
    required String emisorId,
    required String mensaje,
  }) async {
    await client.from('mensajes').insert({
      'incidente_id': incidenteId,
      'emisor_id': emisorId,
      'mensaje': mensaje,
    });
  }

  Stream<List<MensajeModel>> streamMensajes(String incidenteId) {
    return client
        .from('mensajes')
        .stream(primaryKey: ['id'])
        .eq('incidente_id', incidenteId)
        .order('fecha', ascending: true)
        .map((data) => (data as List)
            .map((json) => MensajeModel.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  Future<List<MensajeModel>> _agregarNombresEmisores(
    List<MensajeModel> mensajes,
  ) async {
    final emisorIds = mensajes
        .map((mensaje) => mensaje.emisorId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (emisorIds.isEmpty) return mensajes;

    try {
      final response = await client
          .from('usuarios')
          .select('id,nombre,apellido')
          .inFilter('id', emisorIds);

      final nombresPorId = {
        for (final usuario in response as List)
          usuario['id'] as String: [
            usuario['nombre'],
            usuario['apellido'],
          ]
              .whereType<String>()
              .where((parte) => parte.trim().isNotEmpty)
              .join(' ')
      };

      return mensajes
          .map(
            (mensaje) => mensaje.copyWith(
              emisorNombre: nombresPorId[mensaje.emisorId],
            ),
          )
          .toList();
    } catch (_) {
      return mensajes;
    }
  }
}
