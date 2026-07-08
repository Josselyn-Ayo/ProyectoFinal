import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithPassword(String email, String password);
  Future<void> signUp(String email, String password, Map<String, dynamic> userData);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> getUserById(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String id);
  User? get authUser;
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  User? get authUser => client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  @override
  Future<UserModel> signInWithPassword(String email, String password) async {
    try {
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw AppAuthException('Error al iniciar sesión');
      }

      return await getUserById(userId);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> signUp(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw AppAuthException('Error al registrar usuario');
      }

      userData['id'] = userId;
      userData['correo'] = email;

      await client.from('usuarios').insert(userData);
    } catch (e) {
      throw AppAuthException(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AppAuthException(_extractErrorMessage(e));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) return null;
      return await getUserById(authUser.id);
    } on ServerException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await client
          .from('usuarios')
          .select()
          .eq('id', id)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await client.from('usuarios').select();

      return (response as List<dynamic>)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await client.from('usuarios').upsert(user.toJson());
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await client.from('usuarios').delete().eq('id', id);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is AppAuthException) return error.message;
    if (error is ServerException) return error.message;
    if (error is PostgrestException) return error.message;
    if (error is AuthException) return error.message;
    return error.toString();
  }
}
