import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserEntity? _user;
  bool _loading = false;
  String? _error;

  AuthProvider({required AuthRepository repository}) : _repository = repository {
    _repository.authStateChanges.listen((authState) async {
      if (authState.event == AuthChangeEvent.signedIn) {
        _user = await _repository.getCurrentUser();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        _user = null;
      }
      notifyListeners();
    });
  }

  UserEntity? get user => _user;
  String? get userId => _user?.id;
  String? get userRol => _user?.rol;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      _user = await _repository.getCurrentUser();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repository.login(email, password);
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

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  Future<List<UserEntity>> getAllUsers() async {
    return await _repository.getAllUsers();
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rol,
    String? telefono,
    String? facultad,
    String? carrera,
    String? contactoEmergencia,
  }) async {
    await _repository.register(
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
      rol: rol,
      telefono: telefono,
      facultad: facultad,
      carrera: carrera,
      contactoEmergencia: contactoEmergencia,
    );
  }

  Future<void> updateUser(UserEntity user) async {
    await _repository.updateUser(user);
  }

  Future<void> deleteUser(String id) async {
    await _repository.deleteUser(id);
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rol,
    String? telefono,
    String? facultad,
    String? carrera,
    String? contactoEmergencia,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        rol: rol,
        telefono: telefono,
        facultad: facultad,
        carrera: carrera,
        contactoEmergencia: contactoEmergencia,
      );
      _user = await _repository.getCurrentUser();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
