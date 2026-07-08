import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/guardia.dart';
import '../../domain/usecases/get_guardias.dart';
import '../../domain/usecases/get_mi_guardia.dart';
import '../../domain/usecases/registrar_guardia.dart';
import '../../domain/usecases/editar_guardia.dart';
import '../../domain/usecases/eliminar_guardia.dart';
import '../../domain/usecases/actualizar_estado_guardia.dart';

class GuardiaProvider extends ChangeNotifier {
  final GetGuardiasUseCase? getGuardiasUseCase;
  final GetMiGuardiaUseCase? getMiGuardiaUseCase;
  final RegistrarGuardiaUseCase? registrarGuardiaUseCase;
  final EditarGuardiaUseCase? editarGuardiaUseCase;
  final EliminarGuardiaUseCase? eliminarGuardiaUseCase;
  final ActualizarEstadoGuardiaUseCase? actualizarEstadoGuardiaUseCase;

  List<GuardiaEntity> _guardias = [];
  GuardiaEntity? _miGuardia;
  bool _loading = false;
  String? _error;

  GuardiaProvider({
    this.getGuardiasUseCase,
    this.getMiGuardiaUseCase,
    this.registrarGuardiaUseCase,
    this.editarGuardiaUseCase,
    this.eliminarGuardiaUseCase,
    this.actualizarEstadoGuardiaUseCase,
  });

  List<GuardiaEntity> get guardias => _guardias;
  GuardiaEntity? get miGuardia => _miGuardia;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarGuardias() async {
    if (getGuardiasUseCase == null) return;
    _loading = true;
    notifyListeners();
    try {
      _guardias = await getGuardiasUseCase!(NoParams());
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> cargarMiGuardia(String uid) async {
    if (getMiGuardiaUseCase == null) return;
    _miGuardia =
        await getMiGuardiaUseCase!(GetMiGuardiaParams(usuarioId: uid));
    notifyListeners();
  }

  Future<void> registrarGuardia({
    required String usuarioId,
    String? turno,
    String? estado,
  }) async {
    if (registrarGuardiaUseCase == null) return;
    final guardia = await registrarGuardiaUseCase!(RegistrarGuardiaParams(
      usuarioId: usuarioId,
      turno: turno,
      estado: estado,
    ));
    _guardias.add(guardia);
    notifyListeners();
  }

  Future<void> editarGuardia({
    required String id,
    String? turno,
    String? estado,
  }) async {
    if (editarGuardiaUseCase == null) return;
    final guardia = await editarGuardiaUseCase!(EditarGuardiaParams(
      id: id,
      turno: turno,
      estado: estado,
    ));
    final idx = _guardias.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _guardias[idx] = guardia;
    }
    notifyListeners();
  }

  Future<void> eliminarGuardia(String id) async {
    if (eliminarGuardiaUseCase == null) return;
    await eliminarGuardiaUseCase!(EliminarGuardiaParams(id: id));
    _guardias.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Future<void> actualizarEstado({
    required String guardiaId,
    required String estado,
  }) async {
    if (actualizarEstadoGuardiaUseCase == null) return;
    final guardia = await actualizarEstadoGuardiaUseCase!(
        ActualizarEstadoGuardiaParams(guardiaId: guardiaId, estado: estado));
    final idx = _guardias.indexWhere((g) => g.id == guardiaId);
    if (idx != -1) {
      _guardias[idx] = guardia;
    }
    if (_miGuardia?.id == guardiaId) {
      _miGuardia = guardia;
    }
    notifyListeners();
  }
}
