class AlertaEntity {
  final String? id;
  final String titulo;
  final String mensaje;
  final DateTime? fecha;
  final String? creadorId;
  final bool programada;
  final DateTime? fechaProgramada;

  AlertaEntity({
    this.id,
    required this.titulo,
    required this.mensaje,
    this.fecha,
    this.creadorId,
    this.programada = false,
    this.fechaProgramada,
  });
}
