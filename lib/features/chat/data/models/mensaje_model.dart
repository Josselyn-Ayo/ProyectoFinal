import '../../domain/entities/mensaje.dart';

class MensajeModel extends MensajeEntity {
  MensajeModel({
    required super.id,
    required super.incidenteId,
    required super.emisorId,
    super.emisorNombre,
    required super.mensaje,
    super.fecha,
  });

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    final usuarios = json['usuarios'];
    String? emisorNombre;
    if (usuarios != null && usuarios is Map<String, dynamic>) {
      emisorNombre = usuarios['nombre'] as String?;
    }

    return MensajeModel(
      id: json['id'] as String,
      incidenteId: json['incidente_id'] as String,
      emisorId: json['emisor_id'] as String? ?? '',
      emisorNombre: emisorNombre,
      mensaje: json['mensaje'] as String,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incidente_id': incidenteId,
      'emisor_id': emisorId,
      'mensaje': mensaje,
    };
  }

  MensajeEntity toEntity() => MensajeEntity(
        id: id,
        incidenteId: incidenteId,
        emisorId: emisorId,
        emisorNombre: emisorNombre,
        mensaje: mensaje,
        fecha: fecha,
      );

  MensajeModel copyWith({
    String? emisorNombre,
  }) {
    return MensajeModel(
      id: id,
      incidenteId: incidenteId,
      emisorId: emisorId,
      emisorNombre: emisorNombre ?? this.emisorNombre,
      mensaje: mensaje,
      fecha: fecha,
    );
  }
}
