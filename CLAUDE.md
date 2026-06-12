# Juris Honoris — Guía para IA

Asistente legal con IA para Honduras. App Flutter + Backend Node.js + Portal Admin Next.js.

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Mobile | Flutter 3.44, Dart, BLoC/Cubit, GoRouter, GetIt |
| Backend | Node.js/Express en Railway |
| Admin portal | Next.js 14 en Vercel |
| DB | PostgreSQL en Railway |
| Storage | Cloudinary (documentos de casos) |
| IA | Groq (llama-3.3-70b-versatile) — configurable desde admin |
| Auth | JWT en SharedPreferences + Google Sign-In |

## URLs de producción

- **API:** `https://backend-production-192ce.up.railway.app/api`
- **Admin:** `https://jurishonorisadmin.vercel.app`
- **Default en APK:** `String.fromEnvironment('API_BASE_URL', defaultValue: 'https://backend-production-192ce.up.railway.app/api')`

---

## Arquitectura Flutter

### Patrón de estado: BLoC/Cubit

Cada feature tiene su propio Cubit registrado en `lib/injection_container.dart` vía GetIt (`sl`).

```dart
// Obtener instancia
sl<MiCubit>()

// En router (GoRouter)
BlocProvider(create: (_) => sl<MiCubit>(), child: MiPage())

// En Navigator.push — CRÍTICO: el BlocProvider del router NO aplica aquí
MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => sl<MiCubit>(), child: MiPage()))
```

**Regla importante:** Pages navegadas con `Navigator.push` necesitan su propio `BlocProvider` en el `builder`. El provider del GoRouter no aplica.

### Cubits existentes

| Cubit | Propósito |
|-------|-----------|
| `AuthCubit` | Login, register, Google Sign-In, logout, sesión |
| `CasesCubit` | CRUD de hitos/casos del cliente |
| `LawyersCubit` | Directorio, perfil, solicitudes |
| `ChatIACubit` | Chat legal con IA (Groq/Anthropic/OpenAI) |
| `ChatCubit` | Chat cliente↔abogado (polling 5s) |
| `DocumentsCubit` | Subir/listar/eliminar documentos en Cloudinary |
| `RecommendationsCubit` | Guía de documentos requeridos por IA |
| `AdminCubit` | Config de proveedores IA (SharedPreferences) |

### Navegación

Router en `lib/router/app_router.dart`. Bottom nav de 5 tabs:

```
[ Inicio (0) ]  [ Chat IA (1) ]  [ Tareas (2) ]  [ Dossier (3) ]  [ Perfil (4) ]
```

Navegar entre tabs: `goNavBottom(context, index)` — definido en `app_router.dart`.

### Usuario autenticado

```dart
context.read<AuthCubit>().currentUser  // UserEntity?
context.read<AuthCubit>().isAdmin      // bool
context.read<AuthCubit>().isLawyer     // bool
```

Logout: `AuthCubit.logout()` emite `AuthUnauthenticated` → BlocListener en `app.dart` navega a `/login` automáticamente.

---

## Archivos clave

```
lib/
├── injection_container.dart        ← registrar todos los Cubits aquí
├── router/app_router.dart          ← todas las rutas + goNavBottom()
├── core/constants/
│   ├── api_config.dart             ← URLs de endpoints (baseUrl + rutas)
│   ├── app_colors.dart             ← paleta de colores
│   └── app_sizes.dart              ← espaciados y tamaños
├── features/
│   ├── auth/
│   │   ├── domain/entities/user_entity.dart
│   │   └── presentation/bloc/auth_cubit.dart
│   ├── tasks/presentation/
│   │   ├── bloc/cases_cubit.dart
│   │   ├── bloc/documents_cubit.dart   ← DocumentData model aquí
│   │   └── pages/tasks_page.dart       ← TaskData model aquí
│   ├── lawyers/presentation/bloc/lawyers_cubit.dart
│   ├── ai_chat/presentation/
│   │   ├── bloc/chat_ia_cubit.dart
│   │   ├── bloc/recommendations_cubit.dart  ← RequiredDoc model aquí
│   │   └── pages/
│   │       ├── ai_result_page.dart
│   │       └── required_docs_page.dart
│   └── chat/bloc/chat_cubit.dart
└── shared/widgets/
    ├── app_button.dart
    ├── bottom_nav_bar.dart
    ├── badge_widget.dart
    └── google_sign_in_button.dart
```

---

## Backend Node.js

Ubicación: `api/src/`

### Rutas principales

| Ruta | Archivo |
|------|---------|
| `POST /api/auth/login` | `routes/auth.js` |
| `POST /api/auth/register` | `routes/auth.js` |
| `POST /api/auth/google` | `routes/auth.js` |
| `GET  /api/auth/me` | `routes/auth.js` |
| `GET  /api/cases` | `routes/cases.js` |
| `POST /api/cases` | `routes/cases.js` |
| `GET  /api/cases/:id/documents` | `routes/documents.js` |
| `POST /api/cases/:id/documents` | `routes/documents.js` |
| `GET  /api/lawyers` | `routes/lawyers.js` |
| `POST /api/ai-chat/message` | `routes/ai-chat.js` |
| `POST /api/ai-chat/recommendations` | `routes/ai-chat.js` |
| `GET  /api/admin/*` | `routes/admin.js` |

### DB — Tablas principales

`users`, `cases`, `case_documents`, `lawyer_profiles`, `lawyer_requests`, `chat_messages`, `ai_chat_sessions`, `system_config`

La tabla `system_config` guarda la configuración de IA: `ai_active_provider`, `ai_api_key`, `ai_model`, `ai_master_prompt`.

### Variables de entorno Railway (backend)

```
JWT_SECRET, JWT_EXPIRES_IN
DATABASE_PRIMARY_URL, DATABASE_BACKUP_URL, DATABASE_ACTIVE
CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
GOOGLE_WEB_CLIENT_ID
PORT
```

---

## Módulos completados (cliente)

- Auth: login, registro, Google Sign-In, restaurar sesión
- Home: datos reales (casos + abogados + perfil)
- Chat IA: consulta legal → resultado → crear hito o solicitar abogado
- Guía de documentos: IA genera lista con instituciones HN + Google Maps
- Dossier: lista de hitos desde API
- Tareas: detalle con documentos reales (Cloudinary)
- Perfil: datos reales, logout
- Abogados: directorio, perfil, solicitar
- Chat cliente↔abogado: mensajes en tiempo real (polling)

## Módulos pendientes (panel abogado — equipo)

- `LawyerDashboardPage` — dashboard del abogado
- `LawyerMarketplacePage` — marketplace de casos

---

## Convenciones

- **Locale:** es-HN (español Honduras)
- **Fechas en DB:** ISO 8601, campo `due_date` (snake_case en DB, `dueDate` en Dart)
- **Colores:** siempre usar `AppColors.*` — nunca hardcodear hex salvo grises neutros
- **initState + Cubit:** usar `WidgetsBinding.instance.addPostFrameCallback` para llamar cubits en initState
- **Schema changes:** `prisma db push` en desarrollo (no hay Prisma aquí — SQL directo en Railway)
- No hacer push a `master` sin confirmar con el equipo
