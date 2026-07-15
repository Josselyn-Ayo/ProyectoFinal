import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

type UserPayload = {
  id?: string;
  email: string;
  password?: string;
  nombre: string;
  apellido: string;
  rol: 'estudiante' | 'docente' | 'administrativo' | 'seguridad' | 'admin';
  telefono?: string | null;
  facultad?: string | null;
  carrera?: string | null;
  contactoEmergencia?: string | null;
};

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const authorization = request.headers.get('Authorization') ?? '';

    const callerClient = createClient(url, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const adminClient = createClient(url, serviceRoleKey);
    const { data: authData, error: authError } = await callerClient.auth.getUser();
    if (authError || !authData.user) throw new Error('Sesion no valida');

    const { data: caller, error: callerError } = await adminClient
      .from('usuarios')
      .select('rol')
      .eq('id', authData.user.id)
      .single();
    if (callerError || caller?.rol !== 'admin') {
      throw new Error('Solo un administrador puede gestionar cuentas');
    }

    const { action, user } = await request.json() as {
      action: 'create' | 'update' | 'delete';
      user: UserPayload;
    };

    if (!['create', 'update', 'delete'].includes(action)) {
      throw new Error('Accion no valida');
    }
    if (action !== 'delete' && (!user.email || !user.nombre || !user.apellido)) {
      throw new Error('Nombre, apellido y correo son obligatorios');
    }

    if (action === 'create') {
      if (!user.password || user.password.length < 6) {
        throw new Error('La contrasena debe tener al menos 6 caracteres');
      }
      const { data, error } = await adminClient.auth.admin.createUser({
        email: user.email,
        password: user.password,
        email_confirm: true,
      });
      if (error || !data.user) throw error ?? new Error('No se pudo crear la cuenta');

      const { error: profileError } = await adminClient.from('usuarios').upsert({
        id: data.user.id,
        nombre: user.nombre,
        apellido: user.apellido,
        correo: user.email,
        rol: user.rol,
        telefono: user.telefono ?? null,
        facultad: user.facultad ?? null,
        carrera: user.carrera ?? null,
        contacto_emergencia: user.contactoEmergencia ?? null,
      });
      if (profileError) throw profileError;
      return Response.json({ id: data.user.id }, { headers: corsHeaders });
    }

    if (!user.id) throw new Error('Falta el identificador del usuario');
    if (action === 'delete') {
      if (user.id === authData.user.id) throw new Error('No puedes eliminar tu propia cuenta');
      const { error } = await adminClient.auth.admin.deleteUser(user.id);
      if (error) throw error;
      return Response.json({ ok: true }, { headers: corsHeaders });
    }

    const { error: authUpdateError } = await adminClient.auth.admin.updateUserById(
      user.id,
      { email: user.email },
    );
    if (authUpdateError) throw authUpdateError;

    const { error: profileUpdateError } = await adminClient.from('usuarios').update({
      nombre: user.nombre,
      apellido: user.apellido,
      correo: user.email,
      rol: user.rol,
      telefono: user.telefono ?? null,
      facultad: user.facultad ?? null,
      carrera: user.carrera ?? null,
      contacto_emergencia: user.contactoEmergencia ?? null,
    }).eq('id', user.id);
    if (profileUpdateError) throw profileUpdateError;
    return Response.json({ ok: true }, { headers: corsHeaders });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Error inesperado';
    return Response.json({ error: message }, { status: 400, headers: corsHeaders });
  }
});
