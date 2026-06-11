require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const path    = require('path');
const db      = require('./db');

const app = express();

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

// Servir archivos subidos estáticamente (con auth debería ser por endpoint, esto es para dev)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ── Routes ────────────────────────────────────────────────────
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
    res.status(500).json({ status: 'error', db: err.message });
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
  res.status(500).json({ error: err.message || 'Error interno del servidor' });
});

// ── Arranque ──────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
// Escucha en 0.0.0.0 para ser accesible desde dispositivos móviles en la misma red
app.listen(PORT, '0.0.0.0', async () => {
  try {
    await db.query('select 1');
    console.log(`✓ Juris Honoris API corriendo`);
    console.log(`  Local:    http://localhost:${PORT}/api/health`);
    console.log(`  Red:      http://192.168.1.94:${PORT}/api/health  ← usar en el celular`);
    console.log(`  Emulador: http://10.0.2.2:${PORT}/api/health`);
    console.log(`✓ Base de datos conectada (${process.env.DB_NAME})`);
  } catch (err) {
    console.error('✗ Error de conexión a la base de datos:', err.message);
    console.error('  Verifica las variables en .env');
  }
});
