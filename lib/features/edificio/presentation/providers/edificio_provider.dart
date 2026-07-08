import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/edificio.dart';
import '../../domain/usecases/get_edificios.dart';
import '../../domain/usecases/crear_edificio.dart';
import '../../domain/usecases/editar_edificio.dart';
import '../../domain/usecases/eliminar_edificio.dart';

class EdificioProvider extends ChangeNotifier {
  final GetEdificiosUseCase? getEdificiosUseCase;
  final CrearEdificioUseCase? crearEdificioUseCase;
  final EditarEdificioUseCase? editarEdificioUseCase;
  final EliminarEdificioUseCase? eliminarEdificioUseCase;

  List<EdificioEntity> _edificios = [];
  bool _loading = false;
  String? _error;

  EdificioProvider({
    this.getEdificiosUseCase,
    this.crearEdificioUseCase,
    this.editarEdificioUseCase,
    this.eliminarEdificioUseCase,
  });

  List<EdificioEntity> get edificios => _edificios;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarEdificios() async {
    if (getEdificiosUseCase == null) return;
    _loading = true;
    notifyListeners();
    try {
      _edificios = await getEdificiosUseCase!(NoParams());
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> crearEdificio({
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  }) async {
    if (crearEdificioUseCase == null) return;
    final edificio = await crearEdificioUseCase!(CrearEdificioParams(
      nombre: nombre,
      descripcion: descripcion,
      latitud: latitud,
      longitud: longitud,
    ));
    _edificios.add(edificio);
    notifyListeners();
  }

  Future<void> editarEdificio({
    required String id,
    required String nombre,
    String? descripcion,
    double? latitud,
    double? longitud,
  }) async {
    if (editarEdificioUseCase == null) return;
    final edificio = await editarEdificioUseCase!(EditarEdificioParams(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      latitud: latitud,
      longitud: longitud,
    ));
    final idx = _edificios.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _edificios[idx] = edificio;
    }
    notifyListeners();
  }

  Future<void> eliminarEdificio(String id) async {
    if (eliminarEdificioUseCase == null) return;
    await eliminarEdificioUseCase!(EliminarEdificioParams(id: id));
    _edificios.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
