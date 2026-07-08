import '../../../../../core/usecases/usecase.dart';
import '../repositories/edificio_repository.dart';
import '../entities/edificio.dart';

class CrearEdificioParams {
  final String nombre;
  final String? descripcion;
  final double? latitud;
  final double? longitud;

  CrearEdificioParams({
    required this.nombre,
    this.descripcion,
    this.latitud,
    this.longitud,
  });
}

class CrearEdificioUseCase extends UseCase<EdificioEntity, CrearEdificioParams> {
  final EdificioRepository repository;
  CrearEdificioUseCase(this.repository);

  @override
  Future<EdificioEntity> call(CrearEdificioParams params) async {
    return await repository.crearEdificio(
      nombre: params.nombre,
      descripcion: params.descripcion,
      latitud: params.latitud,
      longitud: params.longitud,
    );
  }
}
