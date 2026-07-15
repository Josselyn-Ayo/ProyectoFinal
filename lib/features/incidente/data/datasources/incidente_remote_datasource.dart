import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incidente_model.dart';

class IncidenteRemoteDatasource {
  final SupabaseClient client;

  IncidenteRemoteDatasource({required this.client});

  Future<IncidenteModel> crearIncidente(Map<String, dynamic> data) async {
    final response = await client.from('incidentes').insert(data).select().single();
    return IncidenteModel.fromJson(response);
  }

  Future<List<IncidenteModel>> getIncidentesUsuario(String usuarioId) async {
    final response = await client
        .from('incidentes')
        .select('*, usuarios(nombre, apellido)')
        .eq('usuario_id', usuarioId)
        .order('fecha', ascending: false);

    return (response as List)
        .map((json) => IncidenteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<IncidenteModel>> getAllIncidentes() async {
    final response = await client
        .from('incidentes')
        .select('*, usuarios(nombre, apellido)')
        .order('fecha', ascending: false);

    return (response as List)
        .map((json) => IncidenteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<IncidenteModel>> getIncidentesActivos() async {
    final response = await client
        .from('incidentes')
        .select('*, usuarios(nombre, apellido)')
        .not('estado', 'in', '(["Cerrado"])')
        .order('fecha', ascending: false);

    return (response as List)
        .map((json) => IncidenteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> actualizarEstado({
    required String incidenteId,
    required Map<String, dynamic> data,
  }) async {
    await client.from('incidentes').update(data).eq('id', incidenteId);
  }

  Future<void> reclamarIncidente(String incidenteId) async {
    await client.rpc('reclamar_incidente', params: {
      'p_incidente_id': incidenteId,
    });
  }

  Future<void> actualizarPrioridad(String incidenteId, String prioridad) async {
    await client
        .from('incidentes')
        .update({'prioridad': prioridad}).eq('id', incidenteId);
  }

  Future<void> eliminarIncidente(String incidenteId) async {
    await client.from('incidentes').delete().eq('id', incidenteId);
  }
}
