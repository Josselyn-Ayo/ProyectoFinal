import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/alerta.dart';
import '../../domain/usecases/get_alertas.dart';
import '../../domain/usecases/crear_alerta.dart';
import '../../domain/usecases/editar_alerta.dart';
import '../../domain/usecases/eliminar_alerta.dart';

class AlertaProvider extends ChangeNotifier {
  final GetAlertasUseCase? getAlertasUseCase;
  final CrearAlertaUseCase? crearAlertaUseCase;
  final EditarAlertaUseCase? editarAlertaUseCase;
  final EliminarAlertaUseCase? eliminarAlertaUseCase;

  List<AlertaEntity> _alertas = [];
  bool _loading = false;
  String? _error;

  AlertaProvider({
    this.getAlertasUseCase,
    this.crearAlertaUseCase,
    this.editarAlertaUseCase,
    this.eliminarAlertaUseCase,
  });

  List<AlertaEntity> get alertas => _alertas;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarAlertas() async {
    if (getAlertasUseCase == null) return;
    _loading = true;
    notifyListeners();
    try {
      _alertas = await getAlertasUseCase!(NoParams());
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> crearAlerta({
    required String titulo,
    required String mensaje,
    required String creadorId,
    bool? programada,
    DateTime? fechaProgramada,
  }) async {
    if (crearAlertaUseCase == null) return;
    final alerta = await crearAlertaUseCase!(CrearAlertaParams(
      titulo: titulo,
      mensaje: mensaje,
      creadorId: creadorId,
      programada: programada,
      fechaProgramada: fechaProgramada,
    ));
    _alertas.add(alerta);
    notifyListeners();
  }

  Future<void> editarAlerta({
    required String id,
    required String titulo,
    required String mensaje,
    bool? programada,
    DateTime? fechaProgramada,
  }) async {
    if (editarAlertaUseCase == null) return;
    final alerta = await editarAlertaUseCase!(EditarAlertaParams(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      programada: programada,
      fechaProgramada: fechaProgramada,
    ));
    final idx = _alertas.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alertas[idx] = alerta;
    }
    notifyListeners();
  }

  Future<void> eliminarAlerta(String id) async {
    if (eliminarAlertaUseCase == null) return;
    await eliminarAlertaUseCase!(EliminarAlertaParams(id: id));
    _alertas.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
