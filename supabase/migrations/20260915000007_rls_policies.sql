-- ==============================================================================
-- Migration: 20260915000007_rls_policies.sql
-- Descrição: Configuração de Row Level Security (RLS) e Políticas de Acesso
-- ==============================================================================

-- 1. Função auxiliar segura para verificação de papel de Administrador
-- (Executa como SECURITY DEFINER para evitar recursão infinita no RLS de user_profiles)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. Habilitar RLS em todas as tabelas
ALTER TABLE public.user_profiles  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nail_colors    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_schedules ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- Políticas para: user_profiles
-- ==============================================================================

-- Usuário vê apenas o próprio perfil; Administrador pode ver todos os perfis
CREATE POLICY "user_profiles_select" ON public.user_profiles
  FOR SELECT USING (
    auth.uid() = id OR public.is_admin()
  );

-- Criação de perfil via signup (permitido se o ID corresponder ao ID autenticado)
CREATE POLICY "user_profiles_insert" ON public.user_profiles
  FOR INSERT WITH CHECK (
    auth.uid() = id AND role = 'user'
  );

-- Atualização: usuário altera seu perfil, mas NUNCA pode se promover a 'admin'
-- Somente quem já é admin ou acesso direto ao banco pode alterar roles
CREATE POLICY "user_profiles_update" ON public.user_profiles
  FOR UPDATE USING (
    auth.uid() = id OR public.is_admin()
  )
  WITH CHECK (
    public.is_admin() OR (role = 'user')
  );

-- ==============================================================================
-- Políticas para: services
-- ==============================================================================

-- Qualquer usuário autenticado pode listar serviços ativos
CREATE POLICY "services_select" ON public.services
  FOR SELECT USING (auth.role() = 'authenticated');

-- Apenas Administrador pode criar, atualizar ou deletar serviços
CREATE POLICY "services_admin_insert" ON public.services
  FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "services_admin_update" ON public.services
  FOR UPDATE USING (public.is_admin());

CREATE POLICY "services_admin_delete" ON public.services
  FOR DELETE USING (public.is_admin());

-- ==============================================================================
-- Políticas para: nail_colors
-- ==============================================================================

-- Qualquer usuário autenticado pode visualizar as cores de esmalte
CREATE POLICY "nail_colors_select" ON public.nail_colors
  FOR SELECT USING (auth.role() = 'authenticated');

-- Apenas Administrador pode cadastrar e editar cores
CREATE POLICY "nail_colors_admin_insert" ON public.nail_colors
  FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "nail_colors_admin_update" ON public.nail_colors
  FOR UPDATE USING (public.is_admin());

CREATE POLICY "nail_colors_admin_delete" ON public.nail_colors
  FOR DELETE USING (public.is_admin());

-- ==============================================================================
-- Políticas para: appointments
-- ==============================================================================

-- Usuário comum vê apenas seus agendamentos; Administrador vê todos
CREATE POLICY "appointments_select" ON public.appointments
  FOR SELECT USING (
    auth.uid() = user_id OR public.is_admin()
  );

-- Usuário pode criar agendamentos somente para si mesmo
CREATE POLICY "appointments_insert" ON public.appointments
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
  );

-- Usuário pode alterar seu próprio agendamento (ex: cancelar); Administrador gerencia qualquer um
CREATE POLICY "appointments_update" ON public.appointments
  FOR UPDATE USING (
    auth.uid() = user_id OR public.is_admin()
  );

-- ==============================================================================
-- Políticas para: work_schedules (bloqueios de horários)
-- ==============================================================================

-- Qualquer usuário autenticado pode consultar horários bloqueados para montar agenda
CREATE POLICY "work_schedules_select" ON public.work_schedules
  FOR SELECT USING (auth.role() = 'authenticated');

-- Apenas Administrador pode criar, editar ou excluir bloqueios de agenda
CREATE POLICY "work_schedules_admin_insert" ON public.work_schedules
  FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "work_schedules_admin_update" ON public.work_schedules
  FOR UPDATE USING (public.is_admin());

CREATE POLICY "work_schedules_admin_delete" ON public.work_schedules
  FOR DELETE USING (public.is_admin());

-- ==============================================================================
-- Políticas para: Storage (bucket nail_colors)
-- ==============================================================================

-- Leitura pública de fotos de esmaltes
CREATE POLICY "nail_colors_storage_select" ON storage.objects
  FOR SELECT USING (bucket_id = 'nail_colors');

-- Apenas admin autenticado pode fazer upload de fotos
CREATE POLICY "nail_colors_storage_insert" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'nail_colors' AND public.is_admin()
  );

CREATE POLICY "nail_colors_storage_update" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'nail_colors' AND public.is_admin()
  );

CREATE POLICY "nail_colors_storage_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'nail_colors' AND public.is_admin()
  );
