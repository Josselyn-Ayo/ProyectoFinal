class IncidenteEntity {
  final String id;
  final String? usuarioId;
  final String? usuarioNombre;
  final String tipo;
  final String? descripcion;
  final double? latitud;
  final double? longitud;
  final String? foto;
  final String estado;
  final String? prioridad;
  final String? respuestaSeguridad;
  final String? guardiaId;
  final DateTime? fecha;

  const IncidenteEntity({
    required this.id,
    this.usuarioId,
    this.usuarioNombre,
    required this.tipo,
    this.descripcion,
    this.latitud,
    this.longitud,
    this.foto,
    required this.estado,
    this.prioridad,
    this.respuestaSeguridad,
    this.guardiaId,
    this.fecha,
  });

  String get estadoFormateado {
    switch (estado) {
      case 'reportado':
        return 'Reportado';
      case 'guardia_asignado':
        return 'Guardia asignado';
      case 'en_camino':
        return 'En camino';
      case 'atendido':
        return 'Atendido';
      case 'cerrado':
        return 'Cerrado';
      default:
        return estado;
    }
  }

  IncidenteEntity copyWith({
    String? id,
    String? usuarioId,
    String? usuarioNombre,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    String? foto,
    String? estado,
    String? prioridad,
    String? respuestaSeguridad,
    String? guardiaId,
    DateTime? fecha,
  }) {
    return IncidenteEntity(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      foto: foto ?? this.foto,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      respuestaSeguridad: respuestaSeguridad ?? this.respuestaSeguridad,
      guardiaId: guardiaId ?? this.guardiaId,
      fecha: fecha ?? this.fecha,
    );
  }
}
