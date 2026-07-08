import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<void> call(RegisterParams params) async {
    await repository.register(
      email: params.email,
      password: params.password,
      nombre: params.nombre,
      apellido: params.apellido,
      rol: params.rol,
      telefono: params.telefono,
      facultad: params.facultad,
      carrera: params.carrera,
      contactoEmergencia: params.contactoEmergencia,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final String rol;
  final String? telefono;
  final String? facultad;
  final String? carrera;
  final String? contactoEmergencia;

  RegisterParams({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    this.facultad,
    this.carrera,
    this.contactoEmergencia,
  });
}
