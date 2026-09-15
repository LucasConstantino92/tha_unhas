-- ==============================================================================
-- Migration: 20260915000002_services.sql
-- Descrição: Criação da tabela services e dados iniciais (seed)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.services (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name              TEXT NOT NULL,
  price             NUMERIC(10,2) NOT NULL DEFAULT 0,
  duration_minutes  INTEGER NOT NULL DEFAULT 30,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_services_name ON public.services(name);

-- Seed de serviços iniciais
INSERT INTO public.services (name, price, duration_minutes) VALUES
  ('Esmaltação Simples', 25.00, 30),
  ('Esmaltação com Gel', 45.00, 60),
  ('Nail Art', 70.00, 90),
  ('Manicure Completa', 40.00, 45)
ON CONFLICT DO NOTHING;
