import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class EvidenciaStorageService {
  final SupabaseClient _client;

  EvidenciaStorageService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<String> subirFoto({
    required File archivo,
    required String incidenteId,
    required String usuarioId,
  }) async {
    final path =
        'incidentes/$incidenteId/${DateTime.now().microsecondsSinceEpoch}.jpg';
    await _client.storage
        .from('evidencias')
        .upload(
          path,
          archivo,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    await _client.from('evidencias').insert({
      'incidente_id': incidenteId,
      'usuario_id': usuarioId,
      'archivo_path': path,
      'tipo': 'foto',
    });
    return path;
  }

  Future<List<String>> obtenerUrlsFotos({
    required String incidenteId,
    String? fotoLegada,
  }) async {
    final response = await _client
        .from('evidencias')
        .select('archivo_path')
        .eq('incidente_id', incidenteId)
        .eq('tipo', 'foto')
        .order('created_at');
    final paths = <String>{
      ...response
          .map((item) => item['archivo_path'] as String?)
          .whereType<String>(),
      if (fotoLegada != null && fotoLegada.isNotEmpty) fotoLegada,
    };

    return Future.wait(
      paths.map(
        (path) =>
            _client.storage.from('evidencias').createSignedUrl(path, 3600),
      ),
    );
  }
}
