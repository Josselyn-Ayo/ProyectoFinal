import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/guardia_model.dart';

abstract class GuardiaRemoteDataSource {
  Future<List<GuardiaModel>> getGuardias();
  Future<GuardiaModel?> getGuardiaByUsuarioId(String uid);
  Future<GuardiaModel> registrarGuardia(GuardiaModel guardia);
  Future<GuardiaModel> editarGuardia(String id, GuardiaModel guardia);
  Future<void> eliminarGuardia(String id);
  Future<GuardiaModel> actualizarEstadoGuardia(String guardiaId, String estado);
}

class GuardiaRemoteDataSourceImpl implements GuardiaRemoteDataSource {
  final client = SupabaseConfig.client;

  @override
  Future<List<GuardiaModel>> getGuardias() async {
    try {
      final response = await client
          .from('guardias')
          .select('*, usuarios(nombre, correo)')
          .order('turno');
      return (response as List).map((j) => GuardiaModel.fromJson(j)).toList();
    } catch (e) {
      throw ServerException('Error al obtener guardias: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaModel?> getGuardiaByUsuarioId(String uid) async {
    try {
      final response = await client
          .from('guardias')
          .select('*, usuarios(nombre, correo)')
          .eq('usuario_id', uid)
          .maybeSingle();
      if (response == null) return null;
      return GuardiaModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al obtener guardia: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaModel> registrarGuardia(GuardiaModel guardia) async {
    try {
      final response = await client
          .from('guardias')
          .insert(guardia.toJson())
          .select()
          .single();
      return GuardiaModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al registrar guardia: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaModel> editarGuardia(String id, GuardiaModel guardia) async {
    try {
      final response = await client
          .from('guardias')
          .update(guardia.toJson())
          .eq('id', id)
          .select()
          .single();
      return GuardiaModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al editar guardia: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarGuardia(String id) async {
    try {
      await client.from('guardias').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Error al eliminar guardia: ${e.toString()}');
    }
  }

  @override
  Future<GuardiaModel> actualizarEstadoGuardia(String guardiaId, String estado) async {
    try {
      final response = await client
          .from('guardias')
          .update({'estado': estado})
          .eq('id', guardiaId)
          .select()
          .single();
      return GuardiaModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al actualizar estado: ${e.toString()}');
    }
  }
}
