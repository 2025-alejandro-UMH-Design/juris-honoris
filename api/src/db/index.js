const { Pool } = require('pg');

function buildPool(prefix) {
  const url = process.env[`DATABASE_${prefix}_URL`];
  if (url) return new Pool({ connectionString: url, ssl: { rejectUnauthorized: false } });

  const host = process.env[`DB_${prefix}_HOST`] || (prefix === 'PRIMARY' ? process.env.DB_HOST : null);
  if (!host) return null;

  return new Pool({
    host,
    port:     parseInt(process.env[`DB_${prefix}_PORT`]     || process.env.DB_PORT     || '5432'),
    database: process.env[`DB_${prefix}_NAME`]              || process.env.DB_NAME     || 'juris_honoris',
    user:     process.env[`DB_${prefix}_USER`]              || process.env.DB_USER     || 'postgres',
    password: process.env[`DB_${prefix}_PASSWORD`]          || process.env.DB_PASSWORD || '',
  });
}

let activeKey = (process.env.DATABASE_ACTIVE || 'primary').toLowerCase();
let pool = buildPool('PRIMARY');

if (!pool) throw new Error('DATABASE_PRIMARY_URL o DB_HOST son requeridos');

pool.on('error', (err) => console.error('PostgreSQL pool error:', err.message));

const query = (text, params) => pool.query(text, params);

async function switchDatabase(target) {
  const key = target.toLowerCase();
  if (key !== 'primary' && key !== 'backup') {
    throw new Error('target debe ser "primary" o "backup"');
  }

  const prefix = key === 'primary' ? 'PRIMARY' : 'BACKUP';
  const newPool = buildPool(prefix);
  if (!newPool) throw new Error(`Base de datos "${key}" no está configurada en las variables de entorno`);

  await newPool.query('SELECT 1');

  const old = pool;
  pool = newPool;
  activeKey = key;
  pool.on('error', (err) => console.error('PostgreSQL pool error:', err.message));
  old.end().catch(() => {});

  return key;
}

function getActiveDatabase() {
  return activeKey;
}

async function getDatabaseStatus() {
  const primaryPool = buildPool('PRIMARY');
  const backupPool  = buildPool('BACKUP');

  async function ping(p) {
    if (!p) return { configured: false, connected: false };
    try {
      await p.query('SELECT 1');
      p.end().catch(() => {});
      return { configured: true, connected: true };
    } catch {
      p.end().catch(() => {});
      return { configured: true, connected: false };
    }
  }

  const [primary, backup] = await Promise.all([ping(primaryPool), ping(backupPool)]);
  return { active: activeKey, primary, backup };
}

module.exports = { query, switchDatabase, getActiveDatabase, getDatabaseStatus };
