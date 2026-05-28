-- ============================================================
-- Sistema de configuración global (para IA y otros settings)
-- Ejecutar después de 02_seed.sql
-- ============================================================
create table if not exists system_config (
  key        text primary key,
  value      text,
  updated_at timestamptz default now()
);

-- Valores por defecto (sin API key — se configura desde el admin web)
insert into system_config (key, value) values
  ('ai_active_provider', 'groq'),
  ('ai_model',           ''),
  ('ai_api_key',         '')
on conflict (key) do nothing;
