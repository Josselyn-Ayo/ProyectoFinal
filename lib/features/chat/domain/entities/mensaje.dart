class MensajeEntity {
  final String id;
  final String incidenteId;
  final String emisorId;
  final String? emisorNombre;
  final String mensaje;
  final DateTime? fecha;

  MensajeEntity({
    required this.id,
    required this.incidenteId,
    required this.emisorId,
    this.emisorNombre,
    required this.mensaje,
    this.fecha,
  });
}
