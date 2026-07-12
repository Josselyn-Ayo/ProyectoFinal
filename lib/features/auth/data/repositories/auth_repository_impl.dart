import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart' as exc;
import '../../../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  User? get authUser => dataSource.authUser;

  @override
  Stream<AuthState> get authStateChanges => dataSource.authStateChanges;

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final user = await dataSource.signInWithPassword(email, password);
      return user;
    } on exc.AppAuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> register({
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
    try {
      final userData = {
        'nombre': nombre,
        'apellido': apellido,
        'rol': rol,
        'telefono': ?telefono,
        'facultad': ?facultad,
        'carrera': ?carrera,
        'contacto_emergencia': ?contactoEmergencia,
      };

      await dataSource.signUp(email, password, userData);
    } on exc.AppAuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      return await dataSource.getUserById(id);
    } on exc.ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      return await dataSource.getAllUsers();
    } on exc.ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final model = user is UserModel ? user : UserModel(
        id: user.id,
        nombre: user.nombre,
        apellido: user.apellido,
        correo: user.correo,
        telefono: user.telefono,
        rol: user.rol,
        facultad: user.facultad,
        carrera: user.carrera,
        foto: user.foto,
        contactoEmergencia: user.contactoEmergencia,
        createdAt: user.createdAt,
      );
      await dataSource.updateUser(model);
    } on exc.ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await dataSource.deleteUser(id);
    } on exc.ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dataSource.signOut();
    } on exc.AppAuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
