import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mensaje_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient client;

  ChatRemoteDataSource({required this.client});

  Future<List<MensajeModel>> getMensajes(String incidenteId) async {
    final response = await client
        .from('mensajes')
        .select('*, usuarios!mensajes_emisor_id_fkey(nombre)')
        .eq('incidente_id', incidenteId)
        .order('fecha', ascending: true);

    return (response as List)
        .map((json) => MensajeModel.fromJson(json as Map<String, dynamic>))
        .toList();
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
}
