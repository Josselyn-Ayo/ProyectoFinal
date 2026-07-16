# CampusSOS

Aplicacion movil de seguridad universitaria desarrollada con Flutter. Permite a estudiantes reportar incidentes y solicitar auxilio SOS; al personal de seguridad atender los casos, comunicarse por chat y adjuntar evidencias; y a administracion gestionar usuarios, alertas, edificios y guardias.

Repositorio: [github.com/Josselyn-Ayo/ProyectoFinal](https://github.com/Josselyn-Ayo/ProyectoFinal)

## Arquitectura

La aplicacion usa Flutter con Provider y una separacion por capas (`presentation`, `domain` y `data`). Supabase proporciona autenticacion, base de datos PostgreSQL con RLS, almacenamiento privado para evidencias y una Edge Function para la administracion de cuentas.

## Requisitos

- Flutter SDK compatible con el proyecto (Dart SDK incluido por Flutter).
- Un proyecto de Supabase.
- Android Studio o un dispositivo/emulador Android; para iOS, macOS con Xcode.
- Supabase CLI, solo para desplegar la Edge Function.

## Instalacion y configuracion

1. Clone el repositorio y entre a la carpeta del proyecto:

   ```bash
   git clone https://github.com/Josselyn-Ayo/ProyectoFinal.git
   cd ProyectoFinal
   ```

2. Instale las dependencias:

   ```bash
   flutter pub get
   ```

3. Cree el archivo `.env` a partir de `.env.example` y complete los valores de su proyecto Supabase:

   ```env
   SUPABASE_URL=https://<project-ref>.supabase.co
   SUPABASE_ANON_KEY=<anon-key>
   GOOGLE_MAPS_API_KEY=<api-key-opcional>
   ```

   `SUPABASE_URL` y `SUPABASE_ANON_KEY` son obligatorios. La interfaz de mapas actual carga mosaicos de OpenStreetMap; las claves de Google que aparecen en los proyectos Android/iOS son marcadores de configuracion y deben sustituirse o eliminarse si no se utilizara Google Maps.

4. En Supabase SQL Editor, ejecute en este orden:

   - `supabase_schema.sql`
   - `supabase_security_hardening.sql`
   - `supabase_guardias_sync.sql` (solo si necesita reaplicar la sincronizacion de guardias)

   Esto crea las tablas, indices, triggers, funcion RPC `reclamar_incidente`, bucket privado `evidencias` y politicas RLS.

5. Despliegue la Edge Function requerida por la administracion de usuarios:

   ```bash
   supabase login
   supabase link --project-ref <project-ref>
   supabase functions deploy admin-users
   supabase secrets set SUPABASE_URL=https://<project-ref>.supabase.co SUPABASE_ANON_KEY=<anon-key> SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
   ```

   Nunca exponga `SUPABASE_SERVICE_ROLE_KEY` en la aplicacion Flutter ni en `.env` versionado.

6. Para Android, revise `android/app/src/main/AndroidManifest.xml`; mantiene permisos de internet, camara y ubicacion. Para iOS, configure los textos de permiso correspondientes en `ios/Runner/Info.plist` si su plataforma los exige.

## Ejecucion

Liste los dispositivos disponibles y ejecute la aplicacion:

```bash
flutter devices
flutter run
```

Para verificar el analisis estatico:

```bash
flutter analyze
```

## Servicios de Supabase utilizados

- **Auth:** registro, inicio y cierre de sesion.
- **PostgreSQL / REST:** usuarios, incidentes, mensajes, alertas, edificios y guardias.
- **Realtime:** actualizacion del chat de incidentes.
- **Storage:** bucket privado `evidencias`, con URLs firmadas de una hora.
- **Edge Function:** `admin-users` para crear, actualizar y eliminar cuentas desde el rol administrador.

## Documentacion tecnica

La documentacion entregable se encuentra en `Documentacion_Tecnica_CampusSOS.docx`. Incluye arquitectura, modelo ER, contrato de API, instrucciones de despliegue y este enlace de repositorio.
