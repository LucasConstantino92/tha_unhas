-- ==============================================================================
-- Migration: 20260915000008_fix_user_profiles_rls.sql
-- Descrição: Ajuste nas políticas RLS de user_profiles para permitir upsert e cadastro sem fricção
-- ==============================================================================

-- Remover políticas anteriores de escrita em user_profiles
DROP POLICY IF EXISTS "user_profiles_insert" ON public.user_profiles;
DROP POLICY IF EXISTS "user_profiles_update" ON public.user_profiles;

-- Política de INSERT: permite inserção se for o próprio usuário autenticado ou durante fluxo de cadastro
CREATE POLICY "user_profiles_insert" ON public.user_profiles
  FOR INSERT WITH CHECK (
    (auth.uid() = id OR auth.uid() IS NULL) AND role = 'user'
  );

-- Política de UPDATE: usuário logado pode atualizar seu perfil, ou se for admin
CREATE POLICY "user_profiles_update" ON public.user_profiles
  FOR UPDATE USING (
    auth.uid() = id OR public.is_admin()
  )
  WITH CHECK (
    public.is_admin() OR role = 'user'
  );
