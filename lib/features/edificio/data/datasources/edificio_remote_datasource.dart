import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/edificio_model.dart';

abstract class EdificioRemoteDataSource {
  Future<List<EdificioModel>> getEdificios();
  Future<EdificioModel> crearEdificio(EdificioModel edificio);
  Future<EdificioModel> editarEdificio(String id, EdificioModel edificio);
  Future<void> eliminarEdificio(String id);
}

class EdificioRemoteDataSourceImpl implements EdificioRemoteDataSource {
  final client = SupabaseConfig.client;

  @override
  Future<List<EdificioModel>> getEdificios() async {
    try {
      final response = await client.from('edificios').select();
      return (response as List).map((j) => EdificioModel.fromJson(j)).toList();
    } catch (e) {
      throw ServerException('Error al obtener edificios: ${e.toString()}');
    }
  }

  @override
  Future<EdificioModel> crearEdificio(EdificioModel edificio) async {
    try {
      final response = await client.from('edificios').insert(edificio.toJson()).select().single();
      return EdificioModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al crear edificio: ${e.toString()}');
    }
  }

  @override
  Future<EdificioModel> editarEdificio(String id, EdificioModel edificio) async {
    try {
      final response = await client.from('edificios').update(edificio.toJson()).eq('id', id).select().single();
      return EdificioModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al editar edificio: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarEdificio(String id) async {
    try {
      await client.from('edificios').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Error al eliminar edificio: ${e.toString()}');
    }
  }
}
