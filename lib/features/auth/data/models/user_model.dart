import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.correo,
    super.telefono,
    required super.rol,
    super.facultad,
    super.carrera,
    super.foto,
    super.contactoEmergencia,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String,
      facultad: json['facultad'] as String?,
      carrera: json['carrera'] as String?,
      foto: json['foto'] as String?,
      contactoEmergencia: json['contacto_emergencia'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'rol': rol,
      'facultad': facultad,
      'carrera': carrera,
      'foto': foto,
      'contacto_emergencia': contactoEmergencia,
    };
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
