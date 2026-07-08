import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'core/config/theme.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/incidente/data/datasources/incidente_remote_datasource.dart';
import 'features/incidente/data/repositories/incidente_repository_impl.dart';
import 'features/incidente/domain/usecases/crear_incidente.dart';
import 'features/incidente/domain/usecases/get_incidentes.dart';
import 'features/incidente/domain/usecases/actualizar_estado.dart';
import 'features/incidente/domain/usecases/actualizar_prioridad.dart';
import 'features/incidente/domain/usecases/eliminar_incidente.dart';
import 'features/incidente/presentation/providers/incidente_provider.dart';

import 'features/alerta/data/datasources/alerta_remote_datasource.dart';
import 'features/alerta/data/repositories/alerta_repository_impl.dart';
import 'features/alerta/domain/usecases/get_alertas.dart';
import 'features/alerta/domain/usecases/crear_alerta.dart';
import 'features/alerta/domain/usecases/editar_alerta.dart';
import 'features/alerta/domain/usecases/eliminar_alerta.dart';
import 'features/alerta/presentation/providers/alerta_provider.dart';

import 'features/edificio/data/datasources/edificio_remote_datasource.dart';
import 'features/edificio/data/repositories/edificio_repository_impl.dart';
import 'features/edificio/domain/usecases/get_edificios.dart';
import 'features/edificio/domain/usecases/crear_edificio.dart';
import 'features/edificio/domain/usecases/editar_edificio.dart';
import 'features/edificio/domain/usecases/eliminar_edificio.dart';
import 'features/edificio/presentation/providers/edificio_provider.dart';

import 'features/guardia/data/datasources/guardia_remote_datasource.dart';
import 'features/guardia/data/repositories/guardia_repository_impl.dart';
import 'features/guardia/domain/usecases/get_guardias.dart';
import 'features/guardia/domain/usecases/get_mi_guardia.dart';
import 'features/guardia/domain/usecases/registrar_guardia.dart';
import 'features/guardia/domain/usecases/editar_guardia.dart';
import 'features/guardia/domain/usecases/eliminar_guardia.dart';
import 'features/guardia/domain/usecases/actualizar_estado_guardia.dart';
import 'features/guardia/presentation/providers/guardia_provider.dart';

import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/get_mensajes.dart';
import 'features/chat/presentation/providers/chat_provider.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/estudiante/presentation/pages/home_page.dart';
import 'features/seguridad/presentation/pages/dashboard_page.dart';
import 'features/admin/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  final client = SupabaseConfig.client;

  final authDataSource = AuthRemoteDataSourceImpl(client: client);
  final authRepo = AuthRepositoryImpl(dataSource: authDataSource);

  final incidenteDataSource = IncidenteRemoteDatasource(client: client);
  final incidenteRepo = IncidenteRepositoryImpl(incidenteDataSource);

  final alertaDataSource = AlertaRemoteDataSourceImpl();
  final alertaRepo = AlertaRepositoryImpl(remoteDataSource: alertaDataSource);

  final edificioDataSource = EdificioRemoteDataSourceImpl();
  final edificioRepo = EdificioRepositoryImpl(remoteDataSource: edificioDataSource);

  final guardiaDataSource = GuardiaRemoteDataSourceImpl();
  final guardiaRepo = GuardiaRepositoryImpl(remoteDataSource: guardiaDataSource);

  final chatDataSource = ChatRemoteDataSource(client: client);
  final chatRepo = ChatRepositoryImpl(remoteDataSource: chatDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(repository: authRepo)..initialize()),

        ChangeNotifierProvider(
          create: (_) => IncidenteProvider(
            crearIncidenteUseCase: CrearIncidenteUseCase(incidenteRepo),
            getIncidentesUsuarioUseCase: GetIncidentesUsuarioUseCase(incidenteRepo),
            getAllIncidentesUseCase: GetAllIncidentesUseCase(incidenteRepo),
            getIncidentesActivosUseCase: GetIncidentesActivosUseCase(incidenteRepo),
            actualizarEstadoUseCase: ActualizarEstadoUseCase(incidenteRepo),
            actualizarPrioridadUseCase: ActualizarPrioridadUseCase(incidenteRepo),
            eliminarIncidenteUseCase: EliminarIncidenteUseCase(incidenteRepo),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => AlertaProvider(
            getAlertasUseCase: GetAlertasUseCase(alertaRepo),
            crearAlertaUseCase: CrearAlertaUseCase(alertaRepo),
            editarAlertaUseCase: EditarAlertaUseCase(alertaRepo),
            eliminarAlertaUseCase: EliminarAlertaUseCase(alertaRepo),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => EdificioProvider(
            getEdificiosUseCase: GetEdificiosUseCase(edificioRepo),
            crearEdificioUseCase: CrearEdificioUseCase(edificioRepo),
            editarEdificioUseCase: EditarEdificioUseCase(edificioRepo),
            eliminarEdificioUseCase: EliminarEdificioUseCase(edificioRepo),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => GuardiaProvider(
            getGuardiasUseCase: GetGuardiasUseCase(guardiaRepo),
            getMiGuardiaUseCase: GetMiGuardiaUseCase(guardiaRepo),
            registrarGuardiaUseCase: RegistrarGuardiaUseCase(guardiaRepo),
            editarGuardiaUseCase: EditarGuardiaUseCase(guardiaRepo),
            eliminarGuardiaUseCase: EliminarGuardiaUseCase(guardiaRepo),
            actualizarEstadoGuardiaUseCase: ActualizarEstadoGuardiaUseCase(guardiaRepo),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            getMensajesUseCase: GetMensajesUseCase(chatRepo),
            enviarMensajeUseCase: EnviarMensajeUseCase(chatRepo),
            chatRepository: chatRepo,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seguridad Universitaria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.loading && auth.user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!auth.isLoggedIn) {
            return const LoginPage();
          }
          final rol = auth.userRol;
          if (rol == 'seguridad') {
            return const DashboardPage();
          } else if (rol == 'admin') {
            return const AdminDashboardPage();
          } else {
            return const EstudianteHomePage();
          }
        },
      ),
    );
  }
}
