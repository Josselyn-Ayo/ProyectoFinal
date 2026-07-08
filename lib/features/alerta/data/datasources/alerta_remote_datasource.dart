import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/alerta_model.dart';

abstract class AlertaRemoteDataSource {
  Future<List<AlertaModel>> getAlertas();
  Future<AlertaModel> crearAlerta(AlertaModel alerta);
  Future<AlertaModel> editarAlerta(String id, AlertaModel alerta);
  Future<void> eliminarAlerta(String id);
}

class AlertaRemoteDataSourceImpl implements AlertaRemoteDataSource {
  final client = SupabaseConfig.client;

  @override
  Future<List<AlertaModel>> getAlertas() async {
    try {
      final response = await client.from('alertas').select().order('fecha', ascending: false);
      return (response as List).map((j) => AlertaModel.fromJson(j)).toList();
    } catch (e) {
      throw ServerException('Error al obtener alertas: ${e.toString()}');
    }
  }

  @override
  Future<AlertaModel> crearAlerta(AlertaModel alerta) async {
    try {
      final response = await client.from('alertas').insert(alerta.toJson()).select().single();
      return AlertaModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al crear alerta: ${e.toString()}');
    }
  }

  @override
  Future<AlertaModel> editarAlerta(String id, AlertaModel alerta) async {
    try {
      final response = await client.from('alertas').update(alerta.toJson()).eq('id', id).select().single();
      return AlertaModel.fromJson(response);
    } catch (e) {
      throw ServerException('Error al editar alerta: ${e.toString()}');
    }
  }

  @override
  Future<void> eliminarAlerta(String id) async {
    try {
      await client.from('alertas').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Error al eliminar alerta: ${e.toString()}');
    }
  }
}
