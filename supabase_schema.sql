-- ============================================
-- ESQUEMA DE BASE DE DATOS - SUPABASE
-- Sistema de Seguridad Universitaria
-- ============================================

-- Tabla: usuarios
CREATE TABLE usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL,
  apellido TEXT NOT NULL,
  correo TEXT NOT NULL UNIQUE,
  telefono TEXT,
  rol TEXT NOT NULL DEFAULT 'estudiante' CHECK (rol IN ('estudiante', 'docente', 'administrativo', 'seguridad', 'admin')),
  facultad TEXT,
  carrera TEXT,
  foto TEXT,
  contacto_emergencia TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: incidentes
CREATE TABLE incidentes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  tipo TEXT NOT NULL,
  descripcion TEXT,
  ubicacion_referencia TEXT,
  anonimo BOOLEAN DEFAULT FALSE,
  latitud DOUBLE PRECISION,
  longitud DOUBLE PRECISION,
  foto TEXT,
  estado TEXT NOT NULL DEFAULT 'Reportado' CHECK (estado IN ('Reportado', 'Guardia asignado', 'En camino', 'Atendido', 'Cerrado')),
  prioridad TEXT DEFAULT 'Media' CHECK (prioridad IN ('Alta', 'Media', 'Baja')),
  respuesta_seguridad TEXT,
  guardia_id UUID,
  fecha TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: mensajes
CREATE TABLE mensajes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incidente_id UUID REFERENCES incidentes(id) ON DELETE CASCADE,
  emisor_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  mensaje TEXT NOT NULL,
  fecha TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: alertas
CREATE TABLE alertas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'informativa' CHECK (tipo IN ('informativa', 'preventiva', 'urgente', 'simulacro')),
  audiencia TEXT NOT NULL DEFAULT 'todos' CHECK (audiencia IN ('todos', 'estudiantes', 'seguridad', 'admin', 'facultad')),
  facultad_objetivo TEXT,
  activa BOOLEAN DEFAULT TRUE,
  fecha TIMESTAMPTZ DEFAULT NOW(),
  creador_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  programada BOOLEAN DEFAULT FALSE,
  fecha_programada TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: edificios
CREATE TABLE edificios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  latitud DOUBLE PRECISION,
  longitud DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: guardias
CREATE TABLE guardias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
  turno TEXT,
  estado TEXT NOT NULL DEFAULT 'Disponible' CHECK (estado IN ('Disponible', 'Ocupado')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDICES
-- ============================================
CREATE INDEX idx_incidentes_usuario ON incidentes(usuario_id);
CREATE INDEX idx_incidentes_estado ON incidentes(estado);
CREATE INDEX idx_incidentes_fecha ON incidentes(fecha DESC);
CREATE INDEX idx_mensajes_incidente ON mensajes(incidente_id);
CREATE INDEX idx_mensajes_fecha ON mensajes(fecha ASC);
CREATE INDEX idx_alertas_fecha ON alertas(fecha DESC);
CREATE INDEX idx_guardias_usuario ON guardias(usuario_id);
CREATE INDEX idx_guardias_estado ON guardias(estado);
CREATE UNIQUE INDEX idx_guardias_usuario_unico ON guardias(usuario_id);

-- ============================================
-- SINCRONIZACION auth.users -> usuarios
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.usuarios (
    id,
    nombre,
    apellido,
    correo,
    telefono,
    rol,
    facultad,
    carrera,
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

INSERT INTO public.usuarios (
  id,
  nombre,
  apellido,
  correo,
  telefono,
  rol,
  facultad,
  carrera,
  contacto_emergencia
)
SELECT
  au.id,
  COALESCE(NULLIF(au.raw_user_meta_data->>'nombre', ''), split_part(au.email, '@', 1), 'Usuario'),
  COALESCE(au.raw_user_meta_data->>'apellido', ''),
  au.email,
  au.raw_user_meta_data->>'telefono',
  'estudiante',
  au.raw_user_meta_data->>'facultad',
  au.raw_user_meta_data->>'carrera',
  au.raw_user_meta_data->>'contacto_emergencia'
FROM auth.users au
ON CONFLICT (id) DO NOTHING;

-- Cada usuario de seguridad necesita un perfil operativo de guardia.
CREATE OR REPLACE FUNCTION public.sync_guardia_from_usuario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.rol = 'seguridad' THEN
    INSERT INTO public.guardias (usuario_id, estado)
    VALUES (NEW.id, 'Disponible')
    ON CONFLICT (usuario_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_usuario_seguridad ON public.usuarios;
CREATE TRIGGER on_usuario_seguridad
  AFTER INSERT OR UPDATE OF rol ON public.usuarios
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_guardia_from_usuario();

-- Completa los perfiles operativos para usuarios de seguridad ya existentes.
INSERT INTO public.guardias (usuario_id, estado)
SELECT id, 'Disponible'
FROM public.usuarios
WHERE rol = 'seguridad'
ON CONFLICT (usuario_id) DO NOTHING;

-- ============================================
-- POLITICAS RLS (Row Level Security)
-- ============================================
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensajes ENABLE ROW LEVEL SECURITY;
ALTER TABLE alertas ENABLE ROW LEVEL SECURITY;
ALTER TABLE edificios ENABLE ROW LEVEL SECURITY;
ALTER TABLE guardias ENABLE ROW LEVEL SECURITY;

-- Usuarios: autenticados pueden leer, admin puede todo
CREATE POLICY "Usuarios autenticados pueden ver usuarios" ON usuarios
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios pueden editar su perfil" ON usuarios
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Usuarios pueden insertar su perfil" ON usuarios
  FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Admin puede insertar usuarios" ON usuarios
  FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'));
CREATE POLICY "Admin puede eliminar usuarios" ON usuarios
  FOR DELETE USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'));

-- Incidentes: autenticados pueden leer, usuario crea, admin/guardia editan
CREATE POLICY "Autenticados pueden ver incidentes" ON incidentes
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios pueden crear incidentes" ON incidentes
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);
CREATE POLICY "Admin y guardia pueden editar incidentes" ON incidentes
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol IN ('admin', 'seguridad'))
  );
CREATE POLICY "Admin puede eliminar incidentes" ON incidentes
  FOR DELETE USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'));

-- Mensajes
CREATE POLICY "Autenticados pueden ver mensajes" ON mensajes
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Usuarios pueden enviar mensajes" ON mensajes
  FOR INSERT WITH CHECK (auth.uid() = emisor_id);

-- Alertas
CREATE POLICY "Autenticados pueden ver alertas" ON alertas
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin puede gestionar alertas" ON alertas
  FOR ALL USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'));

-- Edificios
CREATE POLICY "Autenticados pueden ver edificios" ON edificios
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin puede gestionar edificios" ON edificios
  FOR ALL USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'));

-- Guardias
CREATE POLICY "Autenticados pueden ver guardias" ON guardias
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin puede gestionar guardias" ON guardias
  FOR ALL USING (EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin'));

-- ============================================
-- DATOS DE PRUEBA (Opcional)
-- ============================================

-- Edificios de ejemplo: Campus Jose Ruben Orellana de la EPN, Quito.
-- Coordenadas de referencia para las pruebas del mapa; pueden ajustarse desde el CRUD.
INSERT INTO edificios (nombre, descripcion, latitud, longitud) VALUES
  ('Administracion Central', 'Rectorado y dependencias administrativas', -0.210844, -78.487742),
  ('Biblioteca General', 'Biblioteca y espacios de estudio', -0.209853, -78.489098),
  ('Facultad de Ingenieria de Sistemas', 'Aulas, laboratorios y oficinas de Sistemas', -0.209582, -78.488138),
  ('Facultad de Ingenieria Electrica y Electronica', 'Aulas y laboratorios de ingenieria electrica', -0.210076, -78.487456),
  ('Facultad de Ingenieria Civil y Ambiental', 'Aulas y laboratorios de Ingenieria Civil y Ambiental', -0.210466, -78.489569),
  ('Teatro Politecnico', 'Auditorio principal para actos institucionales', -0.209995, -78.489818),
  ('Cafeteria Central', 'Zona de alimentacion y encuentro estudiantil', -0.210376, -78.488530),
  ('Centro Medico', 'Atencion primaria y primeros auxilios', -0.210700, -78.488267),
  ('Parqueadero Principal', 'Acceso y parqueadero del campus', -0.211057, -78.488952),
  ('Punto de Seguridad Principal', 'Control de acceso por la entrada de Andalucia', -0.211012, -78.487963),
  ('Salida de Emergencia Norte', 'Punto de evacuacion hacia el limite norte del campus', -0.209246, -78.488842),
  ('Salida de Emergencia Sur', 'Punto de evacuacion hacia el limite sur del campus', -0.211296, -78.488470);
