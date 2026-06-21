require('dotenv').config();
require('express-async-errors');
const express   = require('express');
const cors      = require('cors');
const helmet    = require('helmet');
const rateLimit = require('express-rate-limit');
const path      = require('path');
const db        = require('./db');

const app = express();

// ── Seguridad global ───────────────────────────────────────────
app.use(helmet());

// Rate limiting: login (5/15min por IP), IA (30/hora por IP)
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: { error: 'Demasiados intentos. Intenta en 15 minutos.' },
  standardHeaders: true,
  legacyHeaders: false,
});
const aiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 30,
  message: { error: 'Límite de consultas IA alcanzado. Intenta en una hora.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// ── Middleware global ──────────────────────────────────────────
const allowedOrigins = [
  'https://jurishonorisadmin.vercel.app',
  'https://jurishonorisadmin-3yrvweaib-alejandro-solorzano-s-projects.vercel.app',
  /^https:\/\/jurishonorisadmin-.*\.vercel\.app$/,
  'http://localhost:3001',
  'http://localhost:3000',
];
app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);
    const ok = allowedOrigins.some(o => typeof o === 'string' ? o === origin : o.test(origin));
    cb(ok ? null : new Error('CORS not allowed'), ok);
  },
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// ── Routes ────────────────────────────────────────────────────
app.use('/api/auth/login',    loginLimiter);
app.use('/api/ai-chat',       aiLimiter);
app.use('/api/auth',          require('./routes/auth'));
app.use('/api/lawyers',       require('./routes/lawyers'));
app.use('/api/cases',         require('./routes/cases'));
app.use('/api/cases/:caseId/documents', require('./routes/documents'));
app.use('/api/requests',      require('./routes/requests'));
app.use('/api/chat',          require('./routes/chat'));
app.use('/api/ai-chat',       require('./routes/ai-chat'));
app.use('/api/reviews',       require('./routes/reviews'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/admin',          require('./routes/admin'));
app.use('/api/admin/ai-config', require('./routes/ai-config'));

// ── Health check ──────────────────────────────────────────────
app.get('/api/health', async (_req, res) => {
  try {
    await db.query('select 1');
    res.json({ status: 'ok', db: 'connected', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(500).json({ status: 'error', db: 'unavailable' });
  }
});

// ── 404 ───────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ error: 'Ruta no encontrada' }));

// ── Error handler ─────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error(err.message);
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ error: 'El archivo supera el tamaño máximo permitido' });
  }
  // No exponer detalles internos de DB ni stack traces en producción
  const isProd = process.env.NODE_ENV === 'production';
  res.status(500).json({ error: isProd ? 'Error interno del servidor' : (err.message || 'Error interno del servidor') });
});

// ── Arranque ──────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', async () => {
  try {
    await db.query('select 1');
    // Migraciones incrementales
    await db.query(`
      ALTER TABLE users
        ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) NOT NULL DEFAULT 'email'
    `);
    await db.query(`
      ALTER TABLE cases
        ADD COLUMN IF NOT EXISTS notes TEXT
    `);
    await db.query(`
      ALTER TABLE users
        ADD COLUMN IF NOT EXISTS solicitations_reset_at TIMESTAMPTZ
    `);
    await db.query(`
      CREATE TABLE IF NOT EXISTS lawyer_profiles (
        id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        colegiacion_number VARCHAR(100),
        experience_years INT NOT NULL DEFAULT 0,
        about TEXT,
        city VARCHAR(100),
        hourly_rate NUMERIC(10,2),
        rating NUMERIC(3,2) NOT NULL DEFAULT 0,
        total_cases INT NOT NULL DEFAULT 0,
        avail_weekdays BOOLEAN NOT NULL DEFAULT false,
        avail_weekends BOOLEAN NOT NULL DEFAULT false,
        avail_urgent BOOLEAN NOT NULL DEFAULT false,
        verification_status VARCHAR(20) NOT NULL DEFAULT 'pending',
        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
      )
    `);
    await db.query(`
      CREATE TABLE IF NOT EXISTS lawyer_specialties (
        lawyer_id UUID NOT NULL REFERENCES lawyer_profiles(id) ON DELETE CASCADE,
        specialty VARCHAR(100) NOT NULL,
        PRIMARY KEY (lawyer_id, specialty)
      )
    `);
    console.log(`✓ Juris Honoris API corriendo`);
    console.log(`  Local:    http://localhost:${PORT}/api/health`);
    console.log(`  Red:      http://192.168.1.94:${PORT}/api/health  ← usar en el celular`);
    console.log(`  Emulador: http://10.0.2.2:${PORT}/api/health`);
    console.log(`✓ Base de datos conectada`);
  } catch (err) {
    console.error('✗ Error de conexión a la base de datos:', err.message);
    console.error('  Verifica las variables en .env');
  }
});
