-- ==============================================================================
-- Migration: 20260915000004_appointments.sql
-- Descrição: Criação da tabela appointments com chaves estrangeiras e status
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.appointments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  service_id  UUID NOT NULL REFERENCES public.services(id) ON DELETE RESTRICT,
  color_id    UUID REFERENCES public.nail_colors(id) ON DELETE SET NULL,
  start_time  TIMESTAMPTZ NOT NULL,
  end_time    TIMESTAMPTZ NOT NULL,
  status      TEXT NOT NULL DEFAULT 'pending'
                CHECK (status IN (
                  'pending',
                  'confirmed',
                  'cancelled',
                  'rejected',
                  'completed',
                  'in_progress',
                  'no_show'
                )),
  paid_price  NUMERIC(10,2) NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON public.appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_service_id ON public.appointments(service_id);
CREATE INDEX IF NOT EXISTS idx_appointments_color_id ON public.appointments(color_id);
CREATE INDEX IF NOT EXISTS idx_appointments_start_time ON public.appointments(start_time);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON public.appointments(status);
