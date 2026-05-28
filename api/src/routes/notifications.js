const router = require('express').Router();
const db     = require('../db');
const { requireAuth } = require('../middleware/auth');

// GET /api/notifications
router.get('/', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select * from notifications
     where user_id = $1
     order by created_at desc
     limit 50`,
    [req.user.id]
  );
  res.json(rows);
});

// GET /api/notifications/unread-count
router.get('/unread-count', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    'select count(*)::int as count from notifications where user_id = $1 and is_read = false',
    [req.user.id]
  );
  res.json({ count: rows[0].count });
});

// PUT /api/notifications/read-all
router.put('/read-all', requireAuth, async (req, res) => {
  await db.query(
    'update notifications set is_read = true where user_id = $1 and is_read = false',
    [req.user.id]
  );
  res.json({ message: 'Todas las notificaciones marcadas como leídas' });
});

// PUT /api/notifications/:id/read
router.put('/:id/read', requireAuth, async (req, res) => {
  const { rowCount } = await db.query(
    'update notifications set is_read = true where id = $1 and user_id = $2',
    [req.params.id, req.user.id]
  );
  if (!rowCount) return res.status(404).json({ error: 'Notificación no encontrada' });
  res.json({ message: 'Notificación marcada como leída' });
});

module.exports = router;
