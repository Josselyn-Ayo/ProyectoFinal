import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithPassword(String email, String password);
  Future<void> signUp(
    String email,
    String password,
    Map<String, dynamic> userData,
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> getUserById(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUser(UserModel user);
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
  Future<void> updateAdminUser(UserModel user);
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

      final authUser = authResponse.user;
      final userId = authUser?.id;
      if (userId == null) {
        throw AppAuthException('Error al iniciar sesion');
      }

      await _ensureProfileExists(
        authUser,
        fallbackData: {'correo': email},
      );

      return await getUserById(userId);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> signUp(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': userData['nombre'],
          'apellido': userData['apellido'],
          'rol': userData['rol'],
          'telefono': userData['telefono'],
          'facultad': userData['facultad'],
          'carrera': userData['carrera'],
          'contacto_emergencia': userData['contacto_emergencia'],
        },
      );

      final authUser = authResponse.user;
      final userId = authUser?.id;
      if (userId == null) {
        throw AppAuthException('Error al registrar usuario');
      }

      userData['id'] = userId;
      userData['correo'] = email;

      await _ensureProfileExists(authUser, fallbackData: userData);
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

      await _ensureProfileExists(authUser);
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
      final response = await client.from('usuarios').select().eq('id', id).single();

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
  Future<void> createAdminUser({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rol,
    String? telefono,
    String? facultad,
    String? carrera,
  }) async {
    await _invokeAdminUsers({
      'action': 'create',
      'user': {
        'email': email,
        'password': password,
        'nombre': nombre,
        'apellido': apellido,
        'rol': rol,
        'telefono': telefono,
        'facultad': facultad,
        'carrera': carrera,
      },
    });
  }

  @override
  Future<void> updateAdminUser(UserModel user) async {
    await _invokeAdminUsers({
      'action': 'update',
      'user': {
        ...user.toJson(),
        'email': user.correo,
      },
    });
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _invokeAdminUsers({
        'action': 'delete',
        'user': {'id': id},
      });
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<void> _invokeAdminUsers(Map<String, dynamic> body) async {
    try {
      final response = await client.functions.invoke('admin-users', body: body);
      if (response.data is Map && response.data['error'] != null) {
        throw ServerException(response.data['error'].toString());
      }
    } on FunctionException catch (e) {
      throw ServerException(e.details ?? e.reasonPhrase ?? 'Error al gestionar usuario');
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is AppAuthException) return error.message;
    if (error is ServerException) return error.message;
    if (error is PostgrestException) return error.message;
    if (error is AuthException) return error.message;
    return error.toString();
  }

  Future<void> _ensureProfileExists(
    User? authUser, {
    Map<String, dynamic>? fallbackData,
  }) async {
    if (authUser == null) return;

    try {
      final existingProfile = await client
          .from('usuarios')
          .select('id')
          .eq('id', authUser.id)
          .maybeSingle();

      if (existingProfile != null) return;
    } on PostgrestException catch (e) {
      throw AppAuthException(_extractErrorMessage(e));
    }

    final profileData = _buildProfileData(authUser, fallbackData);

    try {
      await client.from('usuarios').upsert(profileData);
    } on PostgrestException catch (e) {
      throw AppAuthException(
        'No se pudo crear el perfil del usuario en la tabla usuarios. '
        'Revisa las politicas RLS de Supabase. Detalle: ${e.message}',
      );
    }
  }

  Map<String, dynamic> _buildProfileData(
    User authUser,
    Map<String, dynamic>? fallbackData,
  ) {
    final metadata = authUser.userMetadata ?? <String, dynamic>{};
    final email = authUser.email ?? (fallbackData?['correo'] as String?) ?? '';
    final emailPrefix = email.contains('@') ? email.split('@').first : email;

    final rawNombre =
        fallbackData?['nombre'] ?? metadata['nombre'] ?? metadata['full_name'];
    final rawApellido = fallbackData?['apellido'] ?? metadata['apellido'];

    final nombre = (rawNombre?.toString().trim().isNotEmpty ?? false)
        ? rawNombre.toString().trim()
        : (emailPrefix.isNotEmpty ? emailPrefix : 'Usuario');

    final apellido = rawApellido?.toString().trim() ?? '';

    return {
      'id': authUser.id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': email,
      'telefono': fallbackData?['telefono'] ?? metadata['telefono'],
      'rol': fallbackData?['rol'] ?? metadata['rol'] ?? 'estudiante',
      'facultad': fallbackData?['facultad'] ?? metadata['facultad'],
      'carrera': fallbackData?['carrera'] ?? metadata['carrera'],
      'contacto_emergencia':
          fallbackData?['contacto_emergencia'] ?? metadata['contacto_emergencia'],
    };
  }
}
