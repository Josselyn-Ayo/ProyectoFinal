import '../../domain/entities/incidente.dart';

class IncidenteModel extends IncidenteEntity {
  const IncidenteModel({
    required super.id,
    super.usuarioId,
    super.usuarioNombre,
    required super.tipo,
    super.descripcion,
    super.latitud,
    super.longitud,
    super.foto,
    required super.estado,
    super.prioridad,
    super.respuestaSeguridad,
    super.guardiaId,
    super.fecha,
  });

  factory IncidenteModel.fromJson(Map<String, dynamic> json) {
    String? usuarioNombre;
    final usuarios = json['usuarios'];
    if (usuarios != null && usuarios is Map<String, dynamic>) {
      usuarioNombre = '${usuarios['nombre'] ?? ''} ${usuarios['apellido'] ?? ''}'.trim();
      if (usuarioNombre.isEmpty) usuarioNombre = null;
    }

    return IncidenteModel(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String?,
      usuarioNombre: usuarioNombre,
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      foto: json['foto'] as String?,
      estado: json['estado'] as String? ?? 'reportado',
      prioridad: json['prioridad'] as String?,
      respuestaSeguridad: json['respuesta_seguridad'] as String?,
      guardiaId: json['guardia_id'] as String?,
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'foto': foto,
      'estado': estado,
      'prioridad': prioridad,
      'respuesta_seguridad': respuestaSeguridad,
      'guardia_id': guardiaId,
    };
  }

  IncidenteEntity toEntity() => IncidenteEntity(
        id: id,
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        tipo: tipo,
        descripcion: descripcion,
        latitud: latitud,
        longitud: longitud,
        foto: foto,
        estado: estado,
        prioridad: prioridad,
        respuestaSeguridad: respuestaSeguridad,
        guardiaId: guardiaId,
        fecha: fecha,
      );
}
