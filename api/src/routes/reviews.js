const router = require('express').Router();
const db     = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');

// POST /api/reviews  — cliente deja reseña al abogado
router.post('/', requireAuth, requireRole('client'), async (req, res) => {
  const { lawyer_id, request_id, rating, comment } = req.body;
  if (!lawyer_id || !rating || !request_id) {
    return res.status(400).json({ error: 'lawyer_id, request_id y rating son requeridos' });
  }
  if (rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'El rating debe estar entre 1 y 5' });
  }

  // Verifica que exista una solicitud aceptada entre cliente y abogado
  const req_ = await db.query(
    `select id from lawyer_requests
     where id = $1 and client_id = $2 and lawyer_id = $3 and status = 'accepted'`,
    [request_id, req.user.id, lawyer_id]
  );
  if (!req_.rows[0]) {
    return res.status(400).json({ error: 'No se puede reseñar sin una solicitud aceptada' });
  }

  const { rows } = await db.query(
    `insert into reviews (reviewer_id, lawyer_id, request_id, rating, comment)
     values ($1, $2, $3, $4, $5)
     on conflict (request_id) do update set rating = $4, comment = $5
     returning *`,
    [req.user.id, lawyer_id, request_id || null, rating, comment?.trim() || null]
  );

  // Recalcula rating promedio del abogado
  await db.query(
    `update lawyer_profiles
     set rating = (select round(avg(rating)::numeric, 2) from reviews where lawyer_id = $1),
         total_cases = (select count(*) from lawyer_requests where lawyer_id = $1 and status = 'accepted')
     where id = $1`,
    [lawyer_id]
  );

  res.status(201).json(rows[0]);
});

module.exports = router;
