import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final/features/auth/domain/entities/user.dart';

void main() {
  UserEntity userWithRole(String rol) => UserEntity(
        id: 'test-user',
        nombre: 'Usuario',
        apellido: 'Prueba',
        correo: 'usuario@epn.edu.ec',
        rol: rol,
      );

  test('clasifica los roles operativos correctamente', () {
    expect(userWithRole('estudiante').esEstudiante, isTrue);
    expect(userWithRole('seguridad').esSeguridad, isTrue);
    expect(userWithRole('admin').esAdmin, isTrue);
    expect(userWithRole('admin').esEstudiante, isFalse);
  });
}
