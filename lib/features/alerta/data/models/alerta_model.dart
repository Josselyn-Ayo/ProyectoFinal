import '../../domain/entities/alerta.dart';

class AlertaModel extends AlertaEntity {
  AlertaModel({
    super.id,
    required super.titulo,
    required super.mensaje,
    super.fecha,
    super.creadorId,
    super.programada,
    super.fechaProgramada,
    super.tipo,
    super.audiencia,
    super.facultadObjetivo,
    super.activa,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    return AlertaModel(
      id: json['id']?.toString(),
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
      creadorId: json['creador_id']?.toString(),
      programada: json['programada'] == true,
      fechaProgramada: json['fecha_programada'] != null
          ? DateTime.tryParse(json['fecha_programada'])
          : null,
      tipo: json['tipo'] ?? 'informativa',
      audiencia: json['audiencia'] ?? 'todos',
      facultadObjetivo: json['facultad_objetivo'],
      activa: json['activa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'fecha': fecha?.toIso8601String(),
      'creador_id': creadorId,
      'programada': programada,
      'fecha_programada': fechaProgramada?.toIso8601String(),
      'tipo': tipo,
      'audiencia': audiencia,
      'facultad_objetivo': facultadObjetivo,
      'activa': activa,
    };
  }
}
