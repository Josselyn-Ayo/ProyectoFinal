import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/incidente.dart';
import '../../domain/usecases/crear_incidente.dart';
import '../../domain/usecases/get_incidentes.dart';
import '../../domain/usecases/actualizar_estado.dart';
import '../../domain/usecases/actualizar_prioridad.dart';
import '../../domain/usecases/eliminar_incidente.dart';

class IncidenteProvider extends ChangeNotifier {
  List<IncidenteEntity> _misIncidentes = [];
  List<IncidenteEntity> _todosIncidentes = [];
  List<IncidenteEntity> _incidentesActivos = [];
  bool _loading = false;
  String? _error;

  final CrearIncidenteUseCase _crearIncidenteUseCase;
  final GetIncidentesUsuarioUseCase _getIncidentesUsuarioUseCase;
  final GetAllIncidentesUseCase _getAllIncidentesUseCase;
  final GetIncidentesActivosUseCase _getIncidentesActivosUseCase;
  final ActualizarEstadoUseCase _actualizarEstadoUseCase;
  final ActualizarPrioridadUseCase _actualizarPrioridadUseCase;
  final EliminarIncidenteUseCase _eliminarIncidenteUseCase;

  IncidenteProvider({
    required CrearIncidenteUseCase crearIncidenteUseCase,
    required GetIncidentesUsuarioUseCase getIncidentesUsuarioUseCase,
    required GetAllIncidentesUseCase getAllIncidentesUseCase,
    required GetIncidentesActivosUseCase getIncidentesActivosUseCase,
    required ActualizarEstadoUseCase actualizarEstadoUseCase,
    required ActualizarPrioridadUseCase actualizarPrioridadUseCase,
    required EliminarIncidenteUseCase eliminarIncidenteUseCase,
  })  : _crearIncidenteUseCase = crearIncidenteUseCase,
        _getIncidentesUsuarioUseCase = getIncidentesUsuarioUseCase,
        _getAllIncidentesUseCase = getAllIncidentesUseCase,
        _getIncidentesActivosUseCase = getIncidentesActivosUseCase,
        _actualizarEstadoUseCase = actualizarEstadoUseCase,
        _actualizarPrioridadUseCase = actualizarPrioridadUseCase,
        _eliminarIncidenteUseCase = eliminarIncidenteUseCase;

  List<IncidenteEntity> get misIncidentes => _misIncidentes;
  List<IncidenteEntity> get todosIncidentes => _todosIncidentes;
  List<IncidenteEntity> get incidentesActivos => _incidentesActivos;
  bool get loading => _loading;
  String? get error => _error;

  int get emergenciasActivas =>
      _incidentesActivos.where((i) => i.estado.toLowerCase() != 'cerrado').length;

  int get incidentesDelDia {
    final hoy = DateTime.now();
    return _todosIncidentes.where((i) {
      if (i.fecha == null) return false;
      return i.fecha!.year == hoy.year &&
          i.fecha!.month == hoy.month &&
          i.fecha!.day == hoy.day;
    }).length;
  }

  Map<String, int> getIncidentesPorTipo() {
    final map = <String, int>{};
    for (final i in _todosIncidentes) {
      map[i.tipo] = (map[i.tipo] ?? 0) + 1;
    }
    return map;
  }

  Future<bool> crearIncidente({
    String? usuarioId,
    required String tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    String? foto,
    bool anonimo = false,
    String? ubicacionReferencia,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _crearIncidenteUseCase(CrearIncidenteParams(
        usuarioId: usuarioId,
        tipo: tipo,
        descripcion: descripcion,
        latitud: latitud,
        longitud: longitud,
        foto: foto,
        anonimo: anonimo,
        ubicacionReferencia: ubicacionReferencia,
      ));
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarMisIncidentes(String usuarioId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _misIncidentes = await _getIncidentesUsuarioUseCase(usuarioId);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> cargarTodosIncidentes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _todosIncidentes = await _getAllIncidentesUseCase(NoParams());
      _incidentesActivos = _todosIncidentes
          .where((incidente) => incidente.estado.toLowerCase() != 'cerrado')
          .toList();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> cargarIncidentesActivos() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _incidentesActivos = await _getIncidentesActivosUseCase(NoParams());
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> actualizarEstado(
      String incidenteId, String estado,
      {String? guardiaId, String? respuesta}) async {
    try {
      await _actualizarEstadoUseCase(ActualizarEstadoParams(
        incidenteId: incidenteId,
        estado: estado,
        guardiaId: guardiaId,
        respuesta: respuesta,
      ));
      await Future.wait([
        cargarIncidentesActivos(),
        cargarTodosIncidentes(),
      ]);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarPrioridad(
      String incidenteId, String prioridad) async {
    try {
      await _actualizarPrioridadUseCase(ActualizarPrioridadParams(
        incidenteId: incidenteId,
        prioridad: prioridad,
      ));
      await cargarTodosIncidentes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarIncidente(String incidenteId) async {
    try {
      await _eliminarIncidenteUseCase(incidenteId);
      _todosIncidentes.removeWhere((i) => i.id == incidenteId);
      _misIncidentes.removeWhere((i) => i.id == incidenteId);
      _incidentesActivos.removeWhere((i) => i.id == incidenteId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
