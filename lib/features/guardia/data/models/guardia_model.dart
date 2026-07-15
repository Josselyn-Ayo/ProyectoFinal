import '../../domain/entities/guardia.dart';

class GuardiaModel extends GuardiaEntity {
  GuardiaModel({
    super.id,
    required super.usuarioId,
    super.usuarioNombre,
    super.usuarioCorreo,
    super.turno,
    super.estado,
  });

  factory GuardiaModel.fromJson(Map<String, dynamic> json) {
    String? usuarioNombre;
    String? usuarioCorreo;

    if (json['usuarios'] != null) {
      final usuario =
          json['usuarios'] is List ? json['usuarios'][0] : json['usuarios'];
      if (usuario != null) {
        usuarioNombre = usuario['nombre'];
        usuarioCorreo = usuario['correo'];
      }
    }

    return GuardiaModel(
      id: json['id']?.toString(),
      usuarioId: json['usuario_id']?.toString() ?? '',
      usuarioNombre: usuarioNombre,
      usuarioCorreo: usuarioCorreo,
      turno: json['turno'],
      estado: json['estado'] ?? 'Disponible',
    );
  }

  Map<String, dynamic> toJson({bool includeUsuarioId = true}) {
    return {
      if (id != null) 'id': id,
      if (includeUsuarioId) 'usuario_id': usuarioId,
      'turno': turno,
      'estado': estado,
    };
  }
}
