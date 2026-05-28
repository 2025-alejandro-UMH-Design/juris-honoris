-- ============================================================
-- JURIS HONORIS — Schema PostgreSQL
-- Archivo: 01_schema.sql
-- Ejecutar primero en DBeaver
-- ============================================================

-- Extensión para UUIDs y bcrypt
create extension if not exists "pgcrypto";

-- ============================================================
-- 1. USERS
-- ============================================================
create table if not exists users (
  id                       uuid default gen_random_uuid() primary key,
  email                    text unique not null,
  password_hash            text not null,
  full_name                text,
  phone                    text,
  dni                      text,
  role                     text not null default 'client'
                             check (role in ('client', 'lawyer', 'admin')),
  plan                     text not null default 'free'
                             check (plan in ('free', 'premium')),
  is_verified              boolean default false,
  avatar_path              text,
  solicitations_this_month int default 0,
  created_at               timestamptz default now(),
  updated_at               timestamptz default now()
);

-- ============================================================
-- 2. LAWYER_PROFILES
-- ============================================================
create table if not exists lawyer_profiles (
  id                  uuid references users(id) on delete cascade primary key,
  colegiacion_number  text unique,
  experience_years    int default 0,
  about               text,
  city                text,
  hourly_rate         decimal(10,2),
  rating              decimal(3,2) default 0.0,
  total_cases         int default 0,
  avail_weekdays      boolean default true,
  avail_weekends      boolean default false,
  avail_urgent        boolean default false,
  verification_status text default 'pending'
                        check (verification_status in ('pending','approved','rejected')),
  rejection_reason    text,
  created_at          timestamptz default now()
);

-- ============================================================
-- 3. LAWYER_SPECIALTIES
-- ============================================================
create table if not exists lawyer_specialties (
  id        uuid default gen_random_uuid() primary key,
  lawyer_id uuid references lawyer_profiles(id) on delete cascade,
  specialty text not null
              check (specialty in (
                'Familia','Penal','Laboral','Mercantil',
                'Civil','Constitucional','Administrativo'
              )),
  unique(lawyer_id, specialty)
);

-- ============================================================
-- 4. CASES  (dossier legal del cliente)
-- ============================================================
create table if not exists cases (
  id          uuid default gen_random_uuid() primary key,
  client_id   uuid references users(id) on delete cascade not null,
  lawyer_id   uuid references lawyer_profiles(id) on delete set null,
  title       text not null,
  description text,
  category    text not null
                check (category in (
                  'family','labor','criminal','commercial',
                  'civil','constitutional','administrative','other'
                )),
  priority    text default 'medium'
                check (priority in ('low','medium','high')),
  status      text default 'pending'
                check (status in ('pending','in_progress','completed','cancelled')),
  due_date    date,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ============================================================
-- 5. CASE_DOCUMENTS
-- ============================================================
create table if not exists case_documents (
  id              uuid default gen_random_uuid() primary key,
  case_id         uuid references cases(id) on delete cascade not null,
  uploaded_by     uuid references users(id) not null,
  name            text not null,
  file_path       text not null,
  file_type       text,
  file_size_bytes bigint,
  created_at      timestamptz default now()
);

-- ============================================================
-- 6. LAWYER_DOCS  (documentos de verificación)
-- ============================================================
create table if not exists lawyer_docs (
  id         uuid default gen_random_uuid() primary key,
  lawyer_id  uuid references lawyer_profiles(id) on delete cascade not null,
  doc_type   text not null
               check (doc_type in ('dni','colegiacion','titulo','otro')),
  file_path  text not null,
  file_type  text,
  created_at timestamptz default now()
);

-- ============================================================
-- 7. LAWYER_REQUESTS
-- ============================================================
create table if not exists lawyer_requests (
  id               uuid default gen_random_uuid() primary key,
  client_id        uuid references users(id) on delete cascade not null,
  lawyer_id        uuid references lawyer_profiles(id) on delete cascade not null,
  case_id          uuid references cases(id) on delete set null,
  case_type        text not null,
  urgency          text default 'normal'
                     check (urgency in ('normal','urgent')),
  description      text,
  status           text default 'pending'
                     check (status in ('pending','accepted','rejected','cancelled')),
  rejection_reason text,
  created_at       timestamptz default now(),
  responded_at     timestamptz
);

-- ============================================================
-- 8. CHAT_MESSAGES  (cliente ↔ abogado)
-- ============================================================
create table if not exists chat_messages (
  id         uuid default gen_random_uuid() primary key,
  request_id uuid references lawyer_requests(id) on delete cascade not null,
  sender_id  uuid references users(id) not null,
  content    text not null,
  is_read    boolean default false,
  created_at timestamptz default now()
);

-- ============================================================
-- 9. AI_CHAT_SESSIONS
-- ============================================================
create table if not exists ai_chat_sessions (
  id           uuid default gen_random_uuid() primary key,
  user_id      uuid references users(id) on delete cascade not null,
  title        text,
  needs_lawyer boolean,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ============================================================
-- 10. AI_CHAT_MESSAGES
-- ============================================================
create table if not exists ai_chat_messages (
  id         uuid default gen_random_uuid() primary key,
  session_id uuid references ai_chat_sessions(id) on delete cascade not null,
  role       text not null check (role in ('user','assistant')),
  content    text not null,
  created_at timestamptz default now()
);

-- ============================================================
-- 11. REVIEWS
-- ============================================================
create table if not exists reviews (
  id          uuid default gen_random_uuid() primary key,
  reviewer_id uuid references users(id) on delete cascade not null,
  lawyer_id   uuid references lawyer_profiles(id) on delete cascade not null,
  request_id  uuid references lawyer_requests(id) unique,
  rating      decimal(2,1) not null check (rating between 1.0 and 5.0),
  comment     text,
  created_at  timestamptz default now()
);

-- ============================================================
-- 12. NOTIFICATIONS
-- ============================================================
create table if not exists notifications (
  id         uuid default gen_random_uuid() primary key,
  user_id    uuid references users(id) on delete cascade not null,
  type       text not null
               check (type in (
                 'request','accepted','rejected','message',
                 'verification','system'
               )),
  title      text not null,
  body       text,
  related_id uuid,
  is_read    boolean default false,
  created_at timestamptz default now()
);

-- ============================================================
-- Índices de rendimiento
-- ============================================================
create index if not exists idx_users_email         on users(email);
create index if not exists idx_users_role          on users(role);
create index if not exists idx_cases_client        on cases(client_id);
create index if not exists idx_cases_status        on cases(status);
create index if not exists idx_requests_client     on lawyer_requests(client_id);
create index if not exists idx_requests_lawyer     on lawyer_requests(lawyer_id);
create index if not exists idx_requests_status     on lawyer_requests(status);
create index if not exists idx_chat_request        on chat_messages(request_id, created_at);
create index if not exists idx_ai_sessions_user    on ai_chat_sessions(user_id);
create index if not exists idx_ai_messages_session on ai_chat_messages(session_id, created_at);
create index if not exists idx_notifications_user  on notifications(user_id, is_read);
create index if not exists idx_reviews_lawyer      on reviews(lawyer_id);
