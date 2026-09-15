-- ==============================================================================
-- Migration: 20260915000005_work_schedules.sql
-- Descrição: Criação da tabela work_schedules (bloqueios de agenda)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.work_schedules (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  start_time  TIMESTAMPTZ NOT NULL,
  end_time    TIMESTAMPTZ NOT NULL,
  is_blocked  BOOLEAN NOT NULL DEFAULT FALSE,
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_work_schedules_start_time ON public.work_schedules(start_time);
