import '../../domain/entities/edificio.dart';

class EdificioModel extends EdificioEntity {
  EdificioModel({
    String? id,
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  }) : super(
          id: id,
          nombre: nombre,
          descripcion: descripcion,
          latitud: latitud,
          longitud: longitud,
        );

  factory EdificioModel.fromJson(Map<String, dynamic> json) {
    return EdificioModel(
      id: json['id']?.toString(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      latitud: json['latitud'] != null
          ? (json['latitud'] as num).toDouble()
          : null,
      longitud: json['longitud'] != null
          ? (json['longitud'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}
