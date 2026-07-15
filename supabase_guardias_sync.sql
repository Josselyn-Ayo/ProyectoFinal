-- Ejecuta este archivo una sola vez en Supabase SQL Editor.
-- Sincroniza usuarios con rol seguridad hacia perfiles operativos de guardia.

CREATE UNIQUE INDEX IF NOT EXISTS idx_guardias_usuario_unico
  ON public.guardias(usuario_id);

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

INSERT INTO public.guardias (usuario_id, estado)
SELECT id, 'Disponible'
FROM public.usuarios
WHERE rol = 'seguridad'
ON CONFLICT (usuario_id) DO NOTHING;
