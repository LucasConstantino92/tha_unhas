-- ==============================================================================
-- Migration: 20260915000006_storage.sql
-- Descrição: Criação do bucket público de Storage para nail_colors
-- ==============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('nail_colors', 'nail_colors', true)
ON CONFLICT (id) DO UPDATE SET public = true;
