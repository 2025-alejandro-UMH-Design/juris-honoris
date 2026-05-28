-- ============================================================
-- JURIS HONORIS — Seed Data
-- Archivo: 02_seed.sql
-- Ejecutar después de 01_schema.sql
--
-- CREDENCIALES DE ACCESO:
-- ┌─────────────┬────────────────────────────────┬─────────────────┐
-- │ Panel       │ Email                          │ Contraseña      │
-- ├─────────────┼────────────────────────────────┼─────────────────┤
-- │ Superadmin  │ admin@jurishonoris.hn          │ Admin2024!      │
-- │ Cliente     │ ana.martinez@correo.hn         │ Cliente2024!    │
-- │ Abogado     │ maria.gonzalez@abogada.hn      │ Abogado2024!    │
-- └─────────────┴────────────────────────────────┴─────────────────┘
--
-- Las contraseñas se hashean con bcrypt (pgcrypto).
-- Para verificar: select (password_hash = crypt('Admin2024!', password_hash))
--                 from users where email = 'admin@jurishonoris.hn';
-- ============================================================

-- ============================================================
-- USERS — IDs fijos para poder referenciarlos en el seed
-- ============================================================

-- Superadmin
insert into users (
  id, email, password_hash, full_name, phone, dni,
  role, plan, is_verified, solicitations_this_month
) values (
  '00000000-0000-0000-0000-000000000001',
  'admin@jurishonoris.hn',
  crypt('Admin2024!', gen_salt('bf', 10)),
  'Administrador Juris Honoris',
  '+50499990001',
  '0801-1990-00001',
  'admin',
  'premium',
  true,
  0
);

-- Cliente demo (Ana Martínez)
insert into users (
  id, email, password_hash, full_name, phone, dni,
  role, plan, is_verified, solicitations_this_month
) values (
  '00000000-0000-0000-0000-000000000002',
  'ana.martinez@correo.hn',
  crypt('Cliente2024!', gen_salt('bf', 10)),
  'Ana Martínez López',
  '+50498880002',
  '0801-1995-00002',
  'client',
  'free',
  true,
  1
);

-- Abogada demo (Dra. María González)
insert into users (
  id, email, password_hash, full_name, phone, dni,
  role, plan, is_verified, solicitations_this_month
) values (
  '00000000-0000-0000-0000-000000000003',
  'maria.gonzalez@abogada.hn',
  crypt('Abogado2024!', gen_salt('bf', 10)),
  'Dra. María González Reyes',
  '+50497770003',
  '0801-1988-00003',
  'lawyer',
  'premium',
  true,
  0
);

-- Abogado extra (Lic. Carlos Méndez) — para poblar el directorio
insert into users (
  id, email, password_hash, full_name, phone, dni,
  role, plan, is_verified, solicitations_this_month
) values (
  '00000000-0000-0000-0000-000000000004',
  'carlos.mendez@abogado.hn',
  crypt('Abogado2024!', gen_salt('bf', 10)),
  'Lic. Carlos Méndez Paz',
  '+50496660004',
  '0501-1985-00004',
  'lawyer',
  'free',
  true,
  0
);

-- ============================================================
-- LAWYER_PROFILES
-- ============================================================

-- Perfil de Dra. María González (Derecho de Familia)
insert into lawyer_profiles (
  id, colegiacion_number, experience_years, about,
  city, hourly_rate, rating, total_cases,
  avail_weekdays, avail_weekends, avail_urgent,
  verification_status
) values (
  '00000000-0000-0000-0000-000000000003',
  'CAH-2012-0847',
  12,
  'Especialista en divorcios, custodia y pensión alimenticia con 12 años de experiencia en el sistema judicial hondureño. Miembro activo del Colegio de Abogados de Honduras.',
  'Tegucigalpa',
  750.00,
  4.8,
  47,
  true,
  false,
  true,
  'approved'
);

-- Especialidades de María González
insert into lawyer_specialties (lawyer_id, specialty) values
  ('00000000-0000-0000-0000-000000000003', 'Familia'),
  ('00000000-0000-0000-0000-000000000003', 'Civil');

-- Perfil de Lic. Carlos Méndez (Derecho Laboral)
insert into lawyer_profiles (
  id, colegiacion_number, experience_years, about,
  city, hourly_rate, rating, total_cases,
  avail_weekdays, avail_weekends, avail_urgent,
  verification_status
) values (
  '00000000-0000-0000-0000-000000000004',
  'CAH-2015-1203',
  9,
  'Experto en despidos injustificados, demandas laborales y negociaciones colectivas. Representación ante el Ministerio de Trabajo.',
  'San Pedro Sula',
  600.00,
  4.6,
  31,
  true,
  true,
  false,
  'approved'
);

-- Especialidades de Carlos Méndez
insert into lawyer_specialties (lawyer_id, specialty) values
  ('00000000-0000-0000-0000-000000000004', 'Laboral'),
  ('00000000-0000-0000-0000-000000000004', 'Mercantil');

-- ============================================================
-- CASES  (casos de Ana Martínez)
-- ============================================================

-- Caso 1: En progreso — asignado a María González
insert into cases (
  id, client_id, lawyer_id, title, description,
  category, priority, status, due_date
) values (
  'aaaaaaaa-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000003',
  'Proceso de divorcio',
  'Divorcio de mutuo acuerdo con hijo menor de edad. Se requiere acuerdo de custodia compartida y pensión alimenticia.',
  'family',
  'high',
  'in_progress',
  '2026-06-15'
);

-- Caso 2: Pendiente — sin abogado asignado
insert into cases (
  id, client_id, lawyer_id, title, description,
  category, priority, status, due_date
) values (
  'aaaaaaaa-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000002',
  null,
  'Trámite sucesoral',
  'Proceso de herencia de bienes inmuebles. Fallecimiento del padre sin testamento. Tres herederos.',
  'other',
  'medium',
  'pending',
  '2026-07-01'
);

-- Caso 3: Completado
insert into cases (
  id, client_id, lawyer_id, title, description,
  category, priority, status, due_date
) values (
  'aaaaaaaa-0000-0000-0000-000000000003',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000004',
  'Revisión contrato arrendamiento',
  'Revisión y firma de contrato de arrendamiento local comercial. Duración 2 años con opción a renovación.',
  'commercial',
  'low',
  'completed',
  '2026-05-20'
);

-- ============================================================
-- CASE_DOCUMENTS  (documentos del caso de divorcio)
-- ============================================================
insert into case_documents (
  case_id, uploaded_by, name, file_path, file_type, file_size_bytes
) values
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'Acta de matrimonio.pdf',
    'uploads/cases/aaaaaaaa-0000-0000-0000-000000000001/acta_matrimonio.pdf',
    'application/pdf',
    245760
  ),
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'DNI Ana Martínez.jpg',
    'uploads/cases/aaaaaaaa-0000-0000-0000-000000000001/dni_cliente.jpg',
    'image/jpeg',
    184320
  );

-- ============================================================
-- LAWYER_REQUESTS
-- ============================================================

-- Solicitud aceptada (Ana → María, caso divorcio)
insert into lawyer_requests (
  id, client_id, lawyer_id, case_id,
  case_type, urgency, description,
  status, responded_at
) values (
  'bbbbbbbb-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000003',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'Representación legal',
  'normal',
  'Necesito asesoría y representación para un proceso de divorcio de mutuo acuerdo. Tenemos un hijo de 7 años y necesitamos acordar la custodia.',
  'accepted',
  now() - interval '5 days'
);

-- Solicitud pendiente (Ana → Carlos, caso herencia)
insert into lawyer_requests (
  id, client_id, lawyer_id, case_id,
  case_type, urgency, description,
  status
) values (
  'bbbbbbbb-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000004',
  'aaaaaaaa-0000-0000-0000-000000000002',
  'Consulta general',
  'normal',
  'Mi padre falleció hace dos meses sin testamento. Somos tres herederos y necesitamos asesoría para el proceso sucesoral de propiedades en Tegucigalpa.',
  'pending'
);

-- ============================================================
-- CHAT_MESSAGES  (conversación Ana ↔ María sobre el divorcio)
-- ============================================================
insert into chat_messages (
  request_id, sender_id, content, is_read, created_at
) values
  (
    'bbbbbbbb-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000003',
    'Buenos días Ana, he revisado su solicitud y con mucho gusto puedo representarle en el proceso de divorcio. ¿Podría enviarme el acta de matrimonio y las DNIs de ambas partes para comenzar?',
    true,
    now() - interval '4 days 10 hours'
  ),
  (
    'bbbbbbbb-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'Muchas gracias Dra. González. Ya le adjunté el acta de matrimonio y mi DNI en el expediente. ¿Cuánto tiempo aproximadamente tarda el proceso?',
    true,
    now() - interval '4 days 9 hours'
  ),
  (
    'bbbbbbbb-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000003',
    'Con acuerdo de mutuo consentimiento y siendo de mutuo acuerdo, el proceso normalmente toma entre 2 y 4 meses en los juzgados de Tegucigalpa. Lo más importante es que tengan el acuerdo de custodia listo antes de presentar la demanda.',
    true,
    now() - interval '4 days 8 hours'
  ),
  (
    'bbbbbbbb-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'Entendido. Ya hablamos con mi esposo y acordamos custodia compartida semana de por medio. ¿Eso facilita el proceso?',
    false,
    now() - interval '1 day'
  );

-- ============================================================
-- AI_CHAT_SESSIONS  (sesión IA de Ana)
-- ============================================================
insert into ai_chat_sessions (
  id, user_id, title, needs_lawyer
) values (
  'cccccccc-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'Consulta sobre proceso de divorcio',
  true
);

-- ============================================================
-- AI_CHAT_MESSAGES
-- ============================================================
insert into ai_chat_messages (session_id, role, content, created_at) values
  (
    'cccccccc-0000-0000-0000-000000000001',
    'user',
    '¿Qué documentos necesito para iniciar un proceso de divorcio en Honduras?',
    now() - interval '6 days'
  ),
  (
    'cccccccc-0000-0000-0000-000000000001',
    'assistant',
    'Para iniciar un proceso de divorcio en Honduras necesitará los siguientes documentos:

1. **Acta de matrimonio original** emitida por el Registro Nacional de las Personas (RNP)
2. **DNI vigente** de ambos cónyuges
3. **Actas de nacimiento** de los hijos menores (si aplica)
4. **Documentos de bienes** en común (escrituras, cuentas bancarias, vehículos)
5. **Acuerdo de custodia** firmado por ambas partes (para divorcio de mutuo acuerdo)

Si el divorcio es de **mutuo acuerdo**, el proceso es más rápido (2-4 meses). Si es **contencioso**, puede extenderse hasta 1-2 años.

[NECESITA_ABOGADO: SI]',
    now() - interval '6 days'
  );

-- ============================================================
-- REVIEWS
-- ============================================================
insert into reviews (
  reviewer_id, lawyer_id, request_id, rating, comment
) values (
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000004',
  'bbbbbbbb-0000-0000-0000-000000000002',
  4.5,
  'Excelente profesional, muy puntual y explicó todo el proceso con claridad. Resolvió mi contrato de arrendamiento en tiempo récord.'
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
insert into notifications (
  user_id, type, title, body, related_id, is_read
) values
  -- Notificación para Ana: solicitud aceptada
  (
    '00000000-0000-0000-0000-000000000002',
    'accepted',
    'Solicitud aceptada',
    'La Dra. María González aceptó tu solicitud de representación para el caso de divorcio.',
    'bbbbbbbb-0000-0000-0000-000000000001',
    true
  ),
  -- Notificación para Ana: mensaje nuevo
  (
    '00000000-0000-0000-0000-000000000002',
    'message',
    'Nuevo mensaje de Dra. González',
    'Tienes un mensaje nuevo en tu caso de divorcio.',
    'bbbbbbbb-0000-0000-0000-000000000001',
    false
  ),
  -- Notificación para María: solicitud nueva
  (
    '00000000-0000-0000-0000-000000000003',
    'request',
    'Nueva solicitud de asesoría',
    'Ana Martínez López solicita representación legal para un proceso de divorcio.',
    'bbbbbbbb-0000-0000-0000-000000000001',
    true
  ),
  -- Notificación para Carlos: solicitud pendiente
  (
    '00000000-0000-0000-0000-000000000004',
    'request',
    'Nueva solicitud de consulta',
    'Ana Martínez López solicita consulta sobre un proceso sucesoral.',
    'bbbbbbbb-0000-0000-0000-000000000002',
    false
  );

-- ============================================================
-- VERIFICACIÓN FINAL
-- Ejecutar estas queries para confirmar que el seed fue exitoso:
-- ============================================================
--
-- select role, count(*) from users group by role;
-- select verification_status, count(*) from lawyer_profiles group by verification_status;
-- select status, count(*) from cases group by status;
-- select status, count(*) from lawyer_requests group by status;
--
-- Para verificar contraseñas (reemplaza el email y contraseña):
-- select (password_hash = crypt('Admin2024!', password_hash)) as valid
-- from users where email = 'admin@jurishonoris.hn';
