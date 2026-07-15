-- Ejecutar una sola vez en Supabase SQL Editor.
-- Refuerza roles, acceso a datos, evidencias y asignacion de incidentes.

-- Las cuentas creadas publicamente siempre nacen como estudiantes.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.usuarios (
    id, nombre, apellido, correo, telefono, rol, facultad, carrera,
    contacto_emergencia
  )
  VALUES (
    NEW.id,
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'nombre', ''), split_part(NEW.email, '@', 1), 'Usuario'),
    COALESCE(NEW.raw_user_meta_data->>'apellido', ''),
    NEW.email,
    NEW.raw_user_meta_data->>'telefono',
    'estudiante',
    NEW.raw_user_meta_data->>'facultad',
    NEW.raw_user_meta_data->>'carrera',
    NEW.raw_user_meta_data->>'contacto_emergencia'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.usuarios
    WHERE id = auth.uid() AND rol = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.is_security()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.usuarios
    WHERE id = auth.uid() AND rol = 'seguridad'
  );
$$;

CREATE OR REPLACE FUNCTION public.can_access_incident(p_incidente_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT public.is_admin()
    OR public.is_security()
    OR EXISTS (
      SELECT 1 FROM public.incidentes
      WHERE id = p_incidente_id AND usuario_id = auth.uid()
    );
$$;

-- Ningun usuario normal puede promoverse ni cambiar el rol de otra cuenta.
CREATE OR REPLACE FUNCTION public.protect_user_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF OLD.rol IS DISTINCT FROM NEW.rol
     AND auth.role() <> 'service_role'
     AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Solo un administrador puede cambiar roles';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_usuario_role ON public.usuarios;
CREATE TRIGGER protect_usuario_role
  BEFORE UPDATE ON public.usuarios
  FOR EACH ROW EXECUTE FUNCTION public.protect_user_role();

-- Evita referencias huerfanas antes de agregar la llave foranea.
UPDATE public.incidentes AS incidente
SET guardia_id = NULL
WHERE guardia_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM public.guardias WHERE id = incidente.guardia_id);

DO $$
BEGIN
  ALTER TABLE public.incidentes
    ADD CONSTRAINT incidentes_guardia_id_fkey
    FOREIGN KEY (guardia_id) REFERENCES public.guardias(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;

CREATE TABLE IF NOT EXISTS public.evidencias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incidente_id UUID NOT NULL REFERENCES public.incidentes(id) ON DELETE CASCADE,
  usuario_id UUID REFERENCES public.usuarios(id) ON DELETE SET NULL,
  archivo_path TEXT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'foto',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_evidencias_incidente
  ON public.evidencias(incidente_id, created_at DESC);

INSERT INTO storage.buckets (id, name, public)
VALUES ('evidencias', 'evidencias', FALSE)
ON CONFLICT (id) DO NOTHING;

-- Reclamo atomico: solo un guardia disponible puede quedarse con un caso reportado.
CREATE OR REPLACE FUNCTION public.reclamar_incidente(p_incidente_id UUID)
RETURNS public.incidentes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_guardia_id UUID;
  v_incidente public.incidentes;
BEGIN
  SELECT id INTO v_guardia_id
  FROM public.guardias
  WHERE usuario_id = auth.uid() AND estado = 'Disponible'
  FOR UPDATE;

  IF v_guardia_id IS NULL THEN
    RAISE EXCEPTION 'No tienes un perfil de guardia disponible';
  END IF;

  UPDATE public.incidentes
  SET estado = 'Guardia asignado', guardia_id = v_guardia_id
  WHERE id = p_incidente_id
    AND estado = 'Reportado'
    AND guardia_id IS NULL
  RETURNING * INTO v_incidente;

  IF v_incidente.id IS NULL THEN
    RAISE EXCEPTION 'El incidente ya fue asignado o cambio de estado';
  END IF;

  UPDATE public.guardias SET estado = 'Ocupado' WHERE id = v_guardia_id;
  RETURN v_incidente;
END;
$$;
GRANT EXECUTE ON FUNCTION public.reclamar_incidente(UUID) TO authenticated;

-- Politicas de perfiles.
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Usuarios pueden editar su perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Usuarios pueden insertar su perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Admin puede insertar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Admin puede eliminar usuarios" ON public.usuarios;
CREATE POLICY "Perfil propio o personal autorizado" ON public.usuarios
  FOR SELECT USING (id = auth.uid() OR public.is_admin() OR public.is_security());
CREATE POLICY "Editar perfil propio o administrado" ON public.usuarios
  FOR UPDATE USING (id = auth.uid() OR public.is_admin())
  WITH CHECK (id = auth.uid() OR public.is_admin());

-- Politicas de incidentes.
DROP POLICY IF EXISTS "Autenticados pueden ver incidentes" ON public.incidentes;
DROP POLICY IF EXISTS "Usuarios pueden crear incidentes" ON public.incidentes;
DROP POLICY IF EXISTS "Admin y guardia pueden editar incidentes" ON public.incidentes;
DROP POLICY IF EXISTS "Admin puede eliminar incidentes" ON public.incidentes;
CREATE POLICY "Acceso autorizado a incidentes" ON public.incidentes
  FOR SELECT USING (usuario_id = auth.uid() OR public.is_admin() OR public.is_security());
CREATE POLICY "Crear incidente propio" ON public.incidentes
  FOR INSERT WITH CHECK (usuario_id = auth.uid());
CREATE POLICY "Actualizar caso asignado o administrado" ON public.incidentes
  FOR UPDATE USING (
    public.is_admin()
    OR (public.is_security() AND guardia_id IN (
      SELECT id FROM public.guardias WHERE usuario_id = auth.uid()
    ))
  ) WITH CHECK (
    public.is_admin()
    OR (public.is_security() AND guardia_id IN (
      SELECT id FROM public.guardias WHERE usuario_id = auth.uid()
    ))
  );
CREATE POLICY "Eliminar incidente administrado" ON public.incidentes
  FOR DELETE USING (public.is_admin());

-- Politicas de chat y evidencias: solo participantes del incidente.
DROP POLICY IF EXISTS "Autenticados pueden ver mensajes" ON public.mensajes;
DROP POLICY IF EXISTS "Usuarios pueden enviar mensajes" ON public.mensajes;
CREATE POLICY "Leer mensajes del caso autorizado" ON public.mensajes
  FOR SELECT USING (public.can_access_incident(incidente_id));
CREATE POLICY "Enviar mensajes al caso autorizado" ON public.mensajes
  FOR INSERT WITH CHECK (
    emisor_id = auth.uid() AND public.can_access_incident(incidente_id)
  );

ALTER TABLE public.evidencias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leer evidencias autorizadas" ON public.evidencias
  FOR SELECT USING (public.can_access_incident(incidente_id));
CREATE POLICY "Subir evidencia autorizada" ON public.evidencias
  FOR INSERT WITH CHECK (
    usuario_id = auth.uid() AND public.can_access_incident(incidente_id)
  );

DROP POLICY IF EXISTS "Leer objetos de evidencia autorizados" ON storage.objects;
DROP POLICY IF EXISTS "Subir objetos de evidencia autorizados" ON storage.objects;
CREATE POLICY "Leer objetos de evidencia autorizados" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'evidencias'
    AND public.can_access_incident((storage.foldername(name))[2]::UUID)
  );
CREATE POLICY "Subir objetos de evidencia autorizados" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'evidencias'
    AND public.can_access_incident((storage.foldername(name))[2]::UUID)
  );

-- Los guardias pueden actualizar solo su propio perfil operativo.
DROP POLICY IF EXISTS "Autenticados pueden ver guardias" ON public.guardias;
DROP POLICY IF EXISTS "Admin puede gestionar guardias" ON public.guardias;
CREATE POLICY "Personal autorizado ve guardias" ON public.guardias
  FOR SELECT USING (public.is_admin() OR public.is_security());
CREATE POLICY "Admin gestiona guardias" ON public.guardias
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Guardia actualiza su estado" ON public.guardias
  FOR UPDATE USING (usuario_id = auth.uid())
  WITH CHECK (usuario_id = auth.uid());
