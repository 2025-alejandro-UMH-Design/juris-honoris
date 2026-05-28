const router  = require('express').Router();
const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');
const db      = require('../db');
const { requireAuth } = require('../middleware/auth');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña requeridos' });
  }

  const { rows } = await db.query(
    'select * from users where email = $1',
    [email.toLowerCase().trim()]
  );
  const user = rows[0];

  if (!user || !(await bcrypt.compare(password, user.password_hash))) {
    return res.status(401).json({ error: 'Credenciales incorrectas' });
  }

  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  res.json({ token, user: sanitize(user) });
});

// POST /api/auth/register  (clientes)
router.post('/register', async (req, res) => {
  const { email, password, full_name, phone } = req.body;
  if (!email || !password || !full_name) {
    return res.status(400).json({ error: 'Email, contraseña y nombre son requeridos' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
  }

  const exists = await db.query('select id from users where email = $1', [email.toLowerCase()]);
  if (exists.rows.length) {
    return res.status(409).json({ error: 'El email ya está registrado' });
  }

  const hash = await bcrypt.hash(password, 10);
  const { rows } = await db.query(
    `insert into users (email, password_hash, full_name, phone, role, plan)
     values ($1, $2, $3, $4, 'client', 'free') returning *`,
    [email.toLowerCase().trim(), hash, full_name.trim(), phone?.trim() || null]
  );

  const token = jwt.sign(
    { id: rows[0].id, email: rows[0].email, role: rows[0].role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  res.status(201).json({ token, user: sanitize(rows[0]) });
});

// GET /api/auth/me
router.get('/me', requireAuth, async (req, res) => {
  const { rows } = await db.query('select * from users where id = $1', [req.user.id]);
  if (!rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' });
  res.json(sanitize(rows[0]));
});

// PUT /api/auth/me  (actualizar perfil)
router.put('/me', requireAuth, async (req, res) => {
  const { full_name, phone, dni } = req.body;
  const { rows } = await db.query(
    `update users set full_name = coalesce($1, full_name),
                      phone     = coalesce($2, phone),
                      dni       = coalesce($3, dni),
                      updated_at = now()
     where id = $4 returning *`,
    [full_name, phone, dni, req.user.id]
  );
  res.json(sanitize(rows[0]));
});

// PUT /api/auth/change-password
router.put('/change-password', requireAuth, async (req, res) => {
  const { current_password, new_password } = req.body;
  if (!current_password || !new_password) {
    return res.status(400).json({ error: 'Contraseña actual y nueva requeridas' });
  }

  const { rows } = await db.query('select password_hash from users where id = $1', [req.user.id]);
  if (!(await bcrypt.compare(current_password, rows[0].password_hash))) {
    return res.status(401).json({ error: 'Contraseña actual incorrecta' });
  }

  const hash = await bcrypt.hash(new_password, 10);
  await db.query('update users set password_hash = $1, updated_at = now() where id = $2', [hash, req.user.id]);
  res.json({ message: 'Contraseña actualizada' });
});

function sanitize(user) {
  const { password_hash, ...rest } = user;
  return rest;
}

module.exports = router;
