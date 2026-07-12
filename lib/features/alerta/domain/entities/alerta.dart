class AlertaEntity {
  final String? id;
  final String titulo;
  final String mensaje;
  final DateTime? fecha;
  final String? creadorId;
  final bool programada;
  final DateTime? fechaProgramada;
  final String tipo;
  final String audiencia;
  final String? facultadObjetivo;
  final bool activa;

  AlertaEntity({
    this.id,
    required this.titulo,
    required this.mensaje,
    this.fecha,
    this.creadorId,
    this.programada = false,
    this.fechaProgramada,
    this.tipo = 'informativa',
    this.audiencia = 'todos',
    this.facultadObjetivo,
    this.activa = true,
  });
}
