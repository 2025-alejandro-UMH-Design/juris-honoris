const router = require('express').Router();
const db     = require('../db');
const { requireAuth } = require('../middleware/auth');

// GET /api/cases  — casos del cliente autenticado
router.get('/', requireAuth, async (req, res) => {
  const { status, category } = req.query;
  let sql = `
    select c.*,
           u.full_name as lawyer_name
    from cases c
    left join users u on u.id = c.lawyer_id
    where c.client_id = $1
  `;
  const params = [req.user.id];

  if (status) {
    params.push(status);
    sql += ` and c.status = $${params.length}`;
  }
  if (category) {
    params.push(category);
    sql += ` and c.category = $${params.length}`;
  }
  sql += ' order by c.created_at desc';

  const { rows } = await db.query(sql, params);
  res.json(rows);
});

// GET /api/cases/:id
router.get('/:id', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select c.*, u.full_name as lawyer_name
     from cases c
     left join users u on u.id = c.lawyer_id
     where c.id = $1 and c.client_id = $2`,
    [req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Caso no encontrado' });
  res.json(rows[0]);
});

// POST /api/cases
router.post('/', requireAuth, async (req, res) => {
  const { title, description, category, priority, due_date } = req.body;
  if (!title || !category) {
    return res.status(400).json({ error: 'Título y categoría son requeridos' });
  }

  const { rows } = await db.query(
    `insert into cases (client_id, title, description, category, priority, due_date)
     values ($1, $2, $3, $4, $5, $6) returning *`,
    [req.user.id, title.trim(), description?.trim(), category, priority || 'medium', due_date || null]
  );
  res.status(201).json(rows[0]);
});

// PUT /api/cases/:id
router.put('/:id', requireAuth, async (req, res) => {
  const { title, description, category, priority, status, due_date, notes } = req.body;

  // Ensure the notes column exists (idempotent migration)
  await db.query(`
    ALTER TABLE cases ADD COLUMN IF NOT EXISTS notes TEXT
  `).catch(() => {});

  const { rows } = await db.query(
    `update cases set
       title       = coalesce($1, title),
       description = coalesce($2, description),
       category    = coalesce($3, category),
       priority    = coalesce($4, priority),
       status      = coalesce($5, status),
       due_date    = coalesce($6, due_date),
       notes       = coalesce($7, notes),
       updated_at  = now()
     where id = $8 and client_id = $9
     returning *`,
    [title, description, category, priority, status, due_date, notes, req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Caso no encontrado' });
  res.json(rows[0]);
});

// DELETE /api/cases/:id
router.delete('/:id', requireAuth, async (req, res) => {
  const { rowCount } = await db.query(
    'delete from cases where id = $1 and client_id = $2',
    [req.params.id, req.user.id]
  );
  if (!rowCount) return res.status(404).json({ error: 'Caso no encontrado' });
  res.json({ message: 'Caso eliminado' });
});

module.exports = router;
