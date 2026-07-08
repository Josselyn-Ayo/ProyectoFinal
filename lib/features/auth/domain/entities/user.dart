class UserEntity {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;
  final String rol;
  final String? facultad;
  final String? carrera;
  final String? foto;
  final String? contactoEmergencia;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono,
    required this.rol,
    this.facultad,
    this.carrera,
    this.foto,
    this.contactoEmergencia,
    this.createdAt,
  });

  String get nombreCompleto => '$nombre $apellido';

  bool get esEstudiante => rol != 'seguridad' && rol != 'admin';
  bool get esSeguridad => rol == 'seguridad';
  bool get esAdmin => rol == 'admin';

  UserEntity copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    String? rol,
    String? facultad,
    String? carrera,
    String? foto,
    String? contactoEmergencia,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      facultad: facultad ?? this.facultad,
      carrera: carrera ?? this.carrera,
      foto: foto ?? this.foto,
      contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
