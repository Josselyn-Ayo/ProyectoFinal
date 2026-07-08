import '../../domain/entities/alerta.dart';

class AlertaModel extends AlertaEntity {
  AlertaModel({
    String? id,
    required String titulo,
    required String mensaje,
    DateTime? fecha,
    String? creadorId,
    bool programada = false,
    DateTime? fechaProgramada,
  }) : super(
          id: id,
          titulo: titulo,
          mensaje: mensaje,
          fecha: fecha,
          creadorId: creadorId,
          programada: programada,
          fechaProgramada: fechaProgramada,
        );

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
    };
  }
}
