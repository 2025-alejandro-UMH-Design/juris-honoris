const router = require('express').Router();
const db     = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');

// GET /api/requests  — lista según el rol
router.get('/', requireAuth, async (req, res) => {
  const { status } = req.query;
  const isLawyer   = req.user.role === 'lawyer';

  let sql = `
    select lr.*,
           uc.full_name  as client_name,
           ul.full_name  as lawyer_name,
           c.title       as case_title
    from lawyer_requests lr
    join users uc on uc.id = lr.client_id
    join users ul on ul.id = lr.lawyer_id
    left join cases c on c.id = lr.case_id
    where ${isLawyer ? 'lr.lawyer_id' : 'lr.client_id'} = $1
  `;
  const params = [req.user.id];

  if (status) {
    params.push(status);
    sql += ` and lr.status = $${params.length}`;
  }
  sql += ' order by lr.created_at desc';

  const { rows } = await db.query(sql, params);
  res.json(rows);
});

// GET /api/requests/:id
router.get('/:id', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select lr.*,
            uc.full_name as client_name,
            ul.full_name as lawyer_name,
            c.title      as case_title
     from lawyer_requests lr
     join users uc on uc.id = lr.client_id
     join users ul on ul.id = lr.lawyer_id
     left join cases c on c.id = lr.case_id
     where lr.id = $1 and (lr.client_id = $2 or lr.lawyer_id = $2)`,
    [req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Solicitud no encontrada' });
  res.json(rows[0]);
});

// POST /api/requests  — cliente crea solicitud a un abogado
router.post('/', requireAuth, requireRole('client'), async (req, res) => {
  const { lawyer_id, case_id, case_type, urgency, description } = req.body;
  if (!lawyer_id || !case_type) {
    return res.status(400).json({ error: 'lawyer_id y case_type son requeridos' });
  }

  // Verifica límite plan free (max 3/mes) — resetea si el mes cambió
  const user = await db.query(
    'select plan, solicitations_this_month, solicitations_reset_at from users where id = $1',
    [req.user.id]
  );
  let { plan, solicitations_this_month } = user.rows[0];
  const resetAt = user.rows[0].solicitations_reset_at;
  const startOfMonth = new Date();
  startOfMonth.setDate(1); startOfMonth.setHours(0, 0, 0, 0);
  if (!resetAt || new Date(resetAt) < startOfMonth) {
    await db.query(
      'update users set solicitations_this_month = 0, solicitations_reset_at = date_trunc(\'month\', now()) where id = $1',
      [req.user.id]
    );
    solicitations_this_month = 0;
  }
  if (plan === 'free' && solicitations_this_month >= 3) {
    return res.status(403).json({ error: 'Límite de solicitudes del plan gratuito alcanzado (3/mes). Actualiza a Premium.' });
  }

  const { rows } = await db.query(
    `insert into lawyer_requests (client_id, lawyer_id, case_id, case_type, urgency, description)
     values ($1, $2, $3, $4, $5, $6) returning *`,
    [req.user.id, lawyer_id, case_id || null, case_type, urgency || 'normal', description?.trim()]
  );

  // Incrementa contador de solicitudes del mes
  await db.query(
    'update users set solicitations_this_month = solicitations_this_month + 1 where id = $1',
    [req.user.id]
  );

  // Crea notificación para el abogado
  const clientRow = await db.query('select full_name from users where id = $1', [req.user.id]);
  await db.query(
    `insert into notifications (user_id, type, title, body, related_id)
     values ($1, 'request', 'Nueva solicitud de asesoría', $2, $3)`,
    [lawyer_id, `${clientRow.rows[0].full_name} te solicita ${case_type}.`, rows[0].id]
  );

  res.status(201).json(rows[0]);
});

// PUT /api/requests/:id/accept  — abogado acepta
router.put('/:id/accept', requireAuth, requireRole('lawyer'), async (req, res) => {
  const { rows } = await db.query(
    `update lawyer_requests
     set status = 'accepted', responded_at = now()
     where id = $1 and lawyer_id = $2 and status = 'pending'
     returning *`,
    [req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Solicitud no encontrada o ya procesada' });

  // Asigna el abogado al caso si existe
  if (rows[0].case_id) {
    await db.query(
      'update cases set lawyer_id = $1 where id = $2',
      [req.user.id, rows[0].case_id]
    );
  }

  // Notificación al cliente
  const lawyerRow = await db.query('select full_name from users where id = $1', [req.user.id]);
  await db.query(
    `insert into notifications (user_id, type, title, body, related_id)
     values ($1, 'accepted', 'Solicitud aceptada', $2, $3)`,
    [rows[0].client_id, `${lawyerRow.rows[0].full_name} aceptó tu solicitud de asesoría.`, rows[0].id]
  );

  res.json(rows[0]);
});

// PUT /api/requests/:id/reject  — abogado rechaza
router.put('/:id/reject', requireAuth, requireRole('lawyer'), async (req, res) => {
  const { reason } = req.body;
  const { rows } = await db.query(
    `update lawyer_requests
     set status = 'rejected', rejection_reason = $1, responded_at = now()
     where id = $2 and lawyer_id = $3 and status = 'pending'
     returning *`,
    [reason || null, req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Solicitud no encontrada o ya procesada' });

  // Notificación al cliente
  await db.query(
    `insert into notifications (user_id, type, title, body, related_id)
     values ($1, 'rejected', 'Solicitud no aceptada', $2, $3)`,
    [rows[0].client_id, reason || 'El abogado no pudo aceptar tu solicitud en este momento.', rows[0].id]
  );

  res.json(rows[0]);
});

// PUT /api/requests/:id/cancel  — cliente cancela
router.put('/:id/cancel', requireAuth, requireRole('client'), async (req, res) => {
  const { rows } = await db.query(
    `update lawyer_requests set status = 'cancelled'
     where id = $1 and client_id = $2 and status = 'pending'
     returning *`,
    [req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Solicitud no encontrada o ya procesada' });
  res.json(rows[0]);
});

module.exports = router;
