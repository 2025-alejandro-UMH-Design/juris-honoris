const router  = require('express').Router();
const bcrypt   = require('bcryptjs');
const db       = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');
const { uploadLawyer } = require('../middleware/upload');

const guard = [requireAuth, requireRole('admin')];

// GET /api/admin/stats  — dashboard
router.get('/stats', ...guard, async (req, res) => {
  const [users, lawyers, cases, requests, pendingVerif] = await Promise.all([
    db.query("select count(*)::int as total from users where role = 'client'"),
    db.query("select count(*)::int as total from lawyer_profiles where verification_status = 'approved'"),
    db.query("select count(*)::int as total from cases"),
    db.query("select count(*)::int as total from lawyer_requests where status = 'pending'"),
    db.query("select count(*)::int as total from lawyer_profiles where verification_status = 'pending'"),
  ]);
  res.json({
    total_clients:          users.rows[0].total,
    total_lawyers_approved: lawyers.rows[0].total,
    total_cases:            cases.rows[0].total,
    pending_requests:       requests.rows[0].total,
    pending_verifications:  pendingVerif.rows[0].total,
  });
});

// GET /api/admin/users  — lista todos los usuarios
router.get('/users', ...guard, async (req, res) => {
  const { role, search } = req.query;
  let sql = 'select id, email, full_name, phone, role, plan, is_verified, solicitations_this_month, created_at from users where 1=1';
  const params = [];

  if (role) { params.push(role); sql += ` and role = $${params.length}`; }
  if (search) { params.push(`%${search}%`); sql += ` and (lower(full_name) like lower($${params.length}) or lower(email) like lower($${params.length}))`; }
  sql += ' order by created_at desc';

  const { rows } = await db.query(sql, params);
  res.json(rows);
});

// PUT /api/admin/users/:id/plan  — cambiar plan
router.put('/users/:id/plan', ...guard, async (req, res) => {
  const { plan } = req.body;
  if (!['free', 'premium'].includes(plan)) {
    return res.status(400).json({ error: 'Plan inválido' });
  }
  await db.query('update users set plan = $1 where id = $2', [plan, req.params.id]);
  res.json({ message: 'Plan actualizado' });
});

// GET /api/admin/lawyers/pending  — abogados pendientes de verificación
router.get('/lawyers/pending', ...guard, async (req, res) => {
  const { rows } = await db.query(
    `select u.id, u.email, u.full_name, u.phone, u.created_at,
            lp.colegiacion_number, lp.experience_years, lp.city, lp.about,
            lp.verification_status,
            array_agg(ls.specialty) filter (where ls.specialty is not null) as specialties,
            array_agg(ld.doc_type || ':' || ld.file_path) filter (where ld.id is not null) as documents
     from lawyer_profiles lp
     join users u on u.id = lp.id
     left join lawyer_specialties ls on ls.lawyer_id = lp.id
     left join lawyer_docs ld on ld.lawyer_id = lp.id
     where lp.verification_status = 'pending'
     group by u.id, u.email, u.full_name, u.phone, u.created_at,
              lp.colegiacion_number, lp.experience_years, lp.city, lp.about, lp.verification_status
     order by u.created_at asc`
  );
  res.json(rows);
});

// PUT /api/admin/lawyers/:id/verify  — aprobar o rechazar abogado
router.put('/lawyers/:id/verify', ...guard, async (req, res) => {
  const { status, reason } = req.body;
  if (!['approved', 'rejected'].includes(status)) {
    return res.status(400).json({ error: 'Estado inválido. Usa approved o rejected.' });
  }

  await db.query(
    `update lawyer_profiles
     set verification_status = $1, rejection_reason = $2
     where id = $3`,
    [status, reason || null, req.params.id]
  );

  if (status === 'approved') {
    await db.query('update users set is_verified = true where id = $1', [req.params.id]);
  }

  // Notificación al abogado
  const msg = status === 'approved'
    ? 'Tu perfil ha sido verificado. Ya apareces en el directorio de abogados.'
    : `Tu verificación fue rechazada. Motivo: ${reason || 'Sin especificar.'}`;

  await db.query(
    `insert into notifications (user_id, type, title, body)
     values ($1, 'verification', $2, $3)`,
    [req.params.id, status === 'approved' ? 'Verificación aprobada' : 'Verificación rechazada', msg]
  );

  res.json({ message: `Abogado ${status === 'approved' ? 'aprobado' : 'rechazado'}` });
});

// POST /api/admin/lawyers/register  — admin registra un abogado directamente
router.post('/lawyers/register', ...guard, async (req, res) => {
  const { email, password, full_name, phone, dni, colegiacion_number, experience_years, about, city, specialties } = req.body;
  if (!email || !password || !full_name) {
    return res.status(400).json({ error: 'email, password y full_name son requeridos' });
  }

  const exists = await db.query('select id from users where email = $1', [email.toLowerCase()]);
  if (exists.rows.length) return res.status(409).json({ error: 'Email ya registrado' });

  const hash = await bcrypt.hash(password, 10);

  const userRes = await db.query(
    `insert into users (email, password_hash, full_name, phone, dni, role, plan, is_verified)
     values ($1, $2, $3, $4, $5, 'lawyer', 'free', false) returning id`,
    [email.toLowerCase(), hash, full_name, phone || null, dni || null]
  );
  const lawyerId = userRes.rows[0].id;

  await db.query(
    `insert into lawyer_profiles (id, colegiacion_number, experience_years, about, city)
     values ($1, $2, $3, $4, $5)`,
    [lawyerId, colegiacion_number || null, experience_years || 0, about || null, city || null]
  );

  if (Array.isArray(specialties)) {
    for (const s of specialties) {
      await db.query(
        'insert into lawyer_specialties (lawyer_id, specialty) values ($1, $2) on conflict do nothing',
        [lawyerId, s]
      );
    }
  }

  res.status(201).json({ id: lawyerId, message: 'Abogado registrado pendiente de verificación' });
});

// DELETE /api/admin/users/:id  — eliminar usuario
router.delete('/users/:id', ...guard, async (req, res) => {
  if (req.params.id === req.user.id) {
    return res.status(400).json({ error: 'No puedes eliminarte a ti mismo' });
  }
  const { rowCount } = await db.query('delete from users where id = $1', [req.params.id]);
  if (!rowCount) return res.status(404).json({ error: 'Usuario no encontrado' });
  res.json({ message: 'Usuario eliminado' });
});

module.exports = router;
