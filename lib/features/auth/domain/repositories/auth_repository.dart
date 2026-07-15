import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);

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
  });

  Future<UserEntity?> getCurrentUser();

  Future<UserEntity?> getUserById(String id);

  Future<List<UserEntity>> getAllUsers();

  Future<void> updateUser(UserEntity user);

  Future<void> createAdminUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rol,
    String? telefono,
    String? facultad,
    String? carrera,
  });

  Future<void> updateAdminUser(UserEntity user);

  Future<void> deleteUser(String id);

  Future<void> logout();

  User? get authUser;

  Stream<AuthState> get authStateChanges;
}
