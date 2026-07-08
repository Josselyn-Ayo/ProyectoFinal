class EdificioEntity {
  final String? id;
  final String nombre;
  final String? descripcion;
  final double? latitud;
  final double? longitud;

  EdificioEntity({
    this.id,
    required this.nombre,
    this.descripcion,
    this.latitud,
    this.longitud,
  });
}
