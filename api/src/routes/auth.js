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
    `insert into users (email, password_hash, full_name, phone, role, plan, auth_provider)
     values ($1, $2, $3, $4, 'client', 'free', 'email') returning *`,
    [email.toLowerCase().trim(), hash, full_name.trim(), phone?.trim() || null]
  );

  const token = jwt.sign(
    { id: rows[0].id, email: rows[0].email, role: rows[0].role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  res.status(201).json({ token, user: sanitize(rows[0]) });
});

// POST /api/auth/google  — login/registro con Google ID token
router.post('/google', async (req, res) => {
  const { id_token } = req.body;
  if (!id_token) return res.status(400).json({ error: 'id_token requerido' });

  try {
    const r = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${id_token}`);
    const info = await r.json();

    if (!r.ok || info.error) {
      return res.status(401).json({ error: 'Token de Google inválido' });
    }

    const webClientId = process.env.GOOGLE_WEB_CLIENT_ID;
    if (!webClientId || info.aud !== webClientId) {
      return res.status(401).json({ error: 'Token no autorizado para esta aplicación' });
    }

    const email = info.email?.toLowerCase();
    const name  = info.name || (email ? email.split('@')[0] : 'Usuario');
    const googleId = info.sub;

    if (!email) return res.status(400).json({ error: 'Email no disponible en la cuenta Google' });

    let { rows } = await db.query('select * from users where email = $1', [email]);
    let user = rows[0];

    if (!user) {
      const randomHash = await bcrypt.hash(Math.random().toString(36) + googleId, 10);
      const insert = await db.query(
        `insert into users (email, password_hash, full_name, role, plan, is_verified, auth_provider)
         values ($1, $2, $3, 'client', 'free', true, 'google') returning *`,
        [email, randomHash, name]
      );
      user = insert.rows[0];
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({ token, user: sanitize(user) });
  } catch (e) {
    res.status(500).json({ error: 'Error al verificar con Google' });
  }
});

// GET /api/auth/me
router.get('/me', requireAuth, async (req, res) => {
  const { rows } = await db.query('select * from users where id = $1', [req.user.id]);
  if (!rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' });
  res.json(sanitize(rows[0]));
});

// PUT /api/auth/me  (actualizar perfil)
router.put('/me', requireAuth, async (req, res) => {
  const { full_name, phone, dni, fcm_token, avatar_url } = req.body;

  // S4: solo permitir URLs de Cloudinary para el avatar
  if (avatar_url != null && typeof avatar_url === 'string' &&
      !avatar_url.startsWith('https://res.cloudinary.com/')) {
    return res.status(400).json({ error: 'URL de avatar inválida' });
  }

  const { rows } = await db.query(
    `update users set full_name  = coalesce($1, full_name),
                      phone      = coalesce($2, phone),
                      dni        = coalesce($3, dni),
                      fcm_token  = coalesce($4, fcm_token),
                      avatar_url = coalesce($5, avatar_url),
                      updated_at = now()
     where id = $6 returning *`,
    [full_name || null, phone || null, dni || null, fcm_token || null, avatar_url || null, req.user.id]
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

// POST /api/auth/register-lawyer  — abogado se registra (queda pendiente de verificación)
router.post('/register-lawyer', async (req, res) => {
  const { email, password, full_name, phone, dni, colegiacion_number, experience_years, city, specialties } = req.body;
  if (!email || !password || !full_name) {
    return res.status(400).json({ error: 'email, password y full_name son requeridos' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
  }

  const exists = await db.query('select id from users where email = $1', [email.toLowerCase().trim()]);
  if (exists.rows.length) return res.status(409).json({ error: 'Email ya registrado' });

  const hash = await bcrypt.hash(password, 10);
  const userRes = await db.query(
    `insert into users (email, password_hash, full_name, phone, dni, role, plan, is_verified, auth_provider)
     values ($1, $2, $3, $4, $5, 'lawyer', 'free', false, 'email') returning id`,
    [email.toLowerCase().trim(), hash, full_name.trim(), phone?.trim() || null, dni?.trim() || null]
  );
  const lawyerId = userRes.rows[0].id;

  await db.query(
    `insert into lawyer_profiles (id, colegiacion_number, experience_years, city, verification_status)
     values ($1, $2, $3, $4, 'approved')`,
    [lawyerId, colegiacion_number?.trim() || null, experience_years ? parseInt(experience_years) : 0, city || null]
  );

  if (Array.isArray(specialties) && specialties.length > 0) {
    for (const s of specialties) {
      await db.query(
        'insert into lawyer_specialties (lawyer_id, specialty) values ($1, $2) on conflict do nothing',
        [lawyerId, s]
      );
    }
  }

  const token = jwt.sign(
    { id: lawyerId, email: email.toLowerCase().trim(), role: 'lawyer' },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
  const userRow = await db.query('select * from users where id = $1', [lawyerId]);
  res.status(201).json({ token, user: sanitize(userRow.rows[0]) });
});

// POST /api/auth/seed-approve  — aprueba abogados de prueba (demo universitario)
router.post('/seed-approve', async (req, res) => {
  const emails = req.body.emails;
  if (!Array.isArray(emails)) return res.status(400).json({ error: 'emails[] requerido' });
  const results = [];
  for (const email of emails) {
    const user = await db.query('select id from users where email = $1', [email.toLowerCase()]);
    if (user.rows[0]) {
      await db.query(
        "update lawyer_profiles set verification_status = 'approved' where id = $1",
        [user.rows[0].id]
      );
      results.push({ email, approved: true });
    } else {
      results.push({ email, approved: false, error: 'not found' });
    }
  }
  res.json({ results });
});

function sanitize(user) {
  const { password_hash, ...rest } = user;
  return rest;
}

module.exports = router;
