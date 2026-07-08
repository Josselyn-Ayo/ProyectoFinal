class GuardiaEntity {
  final String? id;
  final String usuarioId;
  final String? usuarioNombre;
  final String? usuarioCorreo;
  final String? turno;
  final String estado;

  GuardiaEntity({
    this.id,
    required this.usuarioId,
    this.usuarioNombre,
    this.usuarioCorreo,
    this.turno,
    this.estado = 'Disponible',
  });

  bool get disponible => estado == 'Disponible';
}
