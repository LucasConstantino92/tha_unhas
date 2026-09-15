-- ==============================================================================
-- Migration: 20260915000003_nail_colors.sql
-- Descrição: Criação da tabela nail_colors
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.nail_colors (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT,
  hex_code      TEXT NOT NULL,
  image_url     TEXT,
  is_available  BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_nail_colors_available ON public.nail_colors(is_available);
CREATE INDEX IF NOT EXISTS idx_nail_colors_created_at ON public.nail_colors(created_at DESC);
