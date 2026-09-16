-- ==============================================================================
-- Migration: 20260916000001_work_schedules_and_slots.sql
-- Descrição: RPCs para cálculo de horários disponíveis e datas de expediente
-- Regra de negócio: Datas sem registro de trabalho são tratadas como fechadas.
-- ==============================================================================

-- 1. Função: Obter slots (horários) disponíveis para uma data e duração específica
CREATE OR REPLACE FUNCTION public.get_available_slots(
  p_date DATE,
  p_duration_minutes INT,
  p_slot_interval_minutes INT DEFAULT 30
)
RETURNS TABLE (slot_time TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tz TEXT := 'America/Sao_Paulo';
  v_work RECORD;
  v_slot_start TIMESTAMPTZ;
  v_slot_end TIMESTAMPTZ;
  v_now TIMESTAMPTZ := NOW();
  v_today DATE := (NOW() AT TIME ZONE v_tz)::DATE;
BEGIN
  -- Se p_date for anterior ao dia de hoje, nenhum horário está disponível
  IF p_date < v_today THEN
    RETURN;
  END IF;

  -- Se não houver horário de expediente (is_blocked = false) cadastrado para este dia,
  -- a data é tratada como FECHADA e retorna vazio.
  IF NOT EXISTS (
    SELECT 1
    FROM public.work_schedules
    WHERE is_blocked = FALSE
      AND (start_time AT TIME ZONE v_tz)::DATE = p_date
  ) THEN
    RETURN;
  END IF;

  -- Itera por cada turno de trabalho do dia
  FOR v_work IN
    SELECT start_time, end_time
    FROM public.work_schedules
    WHERE is_blocked = FALSE
      AND (start_time AT TIME ZONE v_tz)::DATE = p_date
    ORDER BY start_time ASC
  LOOP
    v_slot_start := v_work.start_time;

    -- Gera slots a partir de start_time enquanto couber a duração do atendimento dentro de end_time
    WHILE (v_slot_start + (p_duration_minutes || ' minutes')::INTERVAL) <= v_work.end_time LOOP
      v_slot_end := v_slot_start + (p_duration_minutes || ' minutes')::INTERVAL;

      -- Se for hoje, ignora horários passados ou em andamento
      IF p_date = v_today AND v_slot_start <= v_now THEN
        v_slot_start := v_slot_start + (p_slot_interval_minutes || ' minutes')::INTERVAL;
        CONTINUE;
      END IF;

      -- Verifica se colide com algum bloqueio cadastrado (is_blocked = TRUE, ex: almoço, folga)
      IF EXISTS (
        SELECT 1
        FROM public.work_schedules ws
        WHERE ws.is_blocked = TRUE
          AND ws.start_time < v_slot_end
          AND ws.end_time > v_slot_start
      ) THEN
        v_slot_start := v_slot_start + (p_slot_interval_minutes || ' minutes')::INTERVAL;
        CONTINUE;
      END IF;

      -- Verifica se colide com algum agendamento ativo
      IF EXISTS (
        SELECT 1
        FROM public.appointments a
        WHERE a.status NOT IN ('cancelled', 'rejected')
          AND a.start_time < v_slot_end
          AND a.end_time > v_slot_start
      ) THEN
        v_slot_start := v_slot_start + (p_slot_interval_minutes || ' minutes')::INTERVAL;
        CONTINUE;
      END IF;

      -- Slot disponível encontrado!
      slot_time := TO_CHAR(v_slot_start AT TIME ZONE v_tz, 'HH24:MI');
      RETURN NEXT;

      -- Avança para o próximo slot pelo intervalo configurado
      v_slot_start := v_slot_start + (p_slot_interval_minutes || ' minutes')::INTERVAL;
    END LOOP;
  END LOOP;

  RETURN;
END;
$$;

-- 2. Função: Obter apenas as datas que possuem expediente aberto em um intervalo
CREATE OR REPLACE FUNCTION public.get_available_dates(
  p_start_date DATE,
  p_end_date DATE
)
RETURNS TABLE (available_date DATE)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tz TEXT := 'America/Sao_Paulo';
BEGIN
  RETURN QUERY
  SELECT DISTINCT (start_time AT TIME ZONE v_tz)::DATE AS available_date
  FROM public.work_schedules
  WHERE is_blocked = FALSE
    AND (start_time AT TIME ZONE v_tz)::DATE BETWEEN p_start_date AND p_end_date
    AND (start_time AT TIME ZONE v_tz)::DATE >= (NOW() AT TIME ZONE v_tz)::DATE
  ORDER BY available_date ASC;
END;
$$;

-- Permissões de execução para usuários autenticados e anônimos
GRANT EXECUTE ON FUNCTION public.get_available_slots(DATE, INT, INT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_available_dates(DATE, DATE) TO authenticated, anon;
