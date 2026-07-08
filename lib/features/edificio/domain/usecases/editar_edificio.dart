import '../../../../../core/usecases/usecase.dart';
import '../repositories/edificio_repository.dart';
import '../entities/edificio.dart';

class EditarEdificioParams {
  final String id;
  final String nombre;
  final String? descripcion;
  final double? latitud;
  final double? longitud;

  EditarEdificioParams({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.latitud,
    this.longitud,
  });
}

class EditarEdificioUseCase extends UseCase<EdificioEntity, EditarEdificioParams> {
  final EdificioRepository repository;
  EditarEdificioUseCase(this.repository);

  @override
  Future<EdificioEntity> call(EditarEdificioParams params) async {
    return await repository.editarEdificio(
      id: params.id,
      nombre: params.nombre,
      descripcion: params.descripcion,
      latitud: params.latitud,
      longitud: params.longitud,
    );
  }
}
