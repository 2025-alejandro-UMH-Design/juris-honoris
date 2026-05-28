const router = require('express').Router();
const db     = require('../db');
const { requireAuth } = require('../middleware/auth');

// Helper: verifica que el usuario pertenezca al request (cliente o abogado)
async function checkRequestAccess(requestId, userId) {
  const { rows } = await db.query(
    'select client_id, lawyer_id, status from lawyer_requests where id = $1',
    [requestId]
  );
  if (!rows[0]) return null;
  const r = rows[0];
  if (r.client_id !== userId && r.lawyer_id !== userId) return null;
  return r;
}

// GET /api/chat/:requestId/messages
router.get('/:requestId/messages', requireAuth, async (req, res) => {
  const request = await checkRequestAccess(req.params.requestId, req.user.id);
  if (!request) return res.status(403).json({ error: 'Sin acceso a este chat' });

  const { rows } = await db.query(
    `select cm.*, u.full_name as sender_name, u.role as sender_role
     from chat_messages cm
     join users u on u.id = cm.sender_id
     where cm.request_id = $1
     order by cm.created_at asc`,
    [req.params.requestId]
  );
  res.json(rows);
});

// POST /api/chat/:requestId/messages  — enviar mensaje
router.post('/:requestId/messages', requireAuth, async (req, res) => {
  const { content } = req.body;
  if (!content?.trim()) return res.status(400).json({ error: 'Mensaje vacío' });

  const request = await checkRequestAccess(req.params.requestId, req.user.id);
  if (!request) return res.status(403).json({ error: 'Sin acceso a este chat' });
  if (request.status !== 'accepted') {
    return res.status(400).json({ error: 'El chat solo está disponible en solicitudes aceptadas' });
  }

  const { rows } = await db.query(
    `insert into chat_messages (request_id, sender_id, content)
     values ($1, $2, $3) returning *`,
    [req.params.requestId, req.user.id, content.trim()]
  );

  // Notificación al otro participante
  const recipientId = req.user.id === request.client_id
    ? request.lawyer_id
    : request.client_id;

  const sender = await db.query('select full_name from users where id = $1', [req.user.id]);
  await db.query(
    `insert into notifications (user_id, type, title, body, related_id)
     values ($1, 'message', 'Nuevo mensaje', $2, $3)`,
    [recipientId, `Mensaje de ${sender.rows[0].full_name}: ${content.trim().slice(0, 60)}`, req.params.requestId]
  );

  res.status(201).json(rows[0]);
});

// PUT /api/chat/:requestId/messages/read  — marcar mensajes como leídos
router.put('/:requestId/messages/read', requireAuth, async (req, res) => {
  const request = await checkRequestAccess(req.params.requestId, req.user.id);
  if (!request) return res.status(403).json({ error: 'Sin acceso a este chat' });

  await db.query(
    `update chat_messages set is_read = true
     where request_id = $1 and sender_id != $2 and is_read = false`,
    [req.params.requestId, req.user.id]
  );
  res.json({ message: 'Mensajes marcados como leídos' });
});

module.exports = router;
