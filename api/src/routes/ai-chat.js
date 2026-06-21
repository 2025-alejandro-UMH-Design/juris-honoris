const router = require('express').Router();
const db     = require('../db');
const { requireAuth } = require('../middleware/auth');

// Prompt de respaldo si no hay uno configurado en la DB
const DEFAULT_PROMPT = `Eres Juris, el asistente legal oficial de Juris Honoris, especializado en el sistema jurídico de Honduras.
Responde siempre en español claro. Al final de CADA respuesta incluye:
[NECESITA_ABOGADO: SI] o [NECESITA_ABOGADO: NO] según corresponda.
Si incluyes [NECESITA_ABOGADO: SI], agrega también [ESPECIALIDAD: X] donde X es exactamente una de: Familia, Penal, Laboral, Mercantil, Civil, Constitucional, Administrativo.
IMPORTANTE: No proporcionas representación legal, solo orientación informativa.`;

async function getSystemPrompt() {
  const { rows } = await db.query(
    "select value from system_config where key = 'ai_master_prompt'"
  );
  return rows[0]?.value || DEFAULT_PROMPT;
}

// GET /api/ai-chat/status  — verifica si la IA está configurada
router.get('/status', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    "select value from system_config where key = 'ai_api_key'"
  );
  res.json({ configured: !!(rows[0]?.value) });
});

// POST /api/ai-chat/message  — Flutter envía aquí, el backend llama al proveedor IA
router.post('/message', requireAuth, async (req, res) => {
  const { message, history = [] } = req.body;
  if (!message?.trim()) return res.status(400).json({ error: 'message requerido' });

  const [cfg, systemPrompt] = await Promise.all([
    db.query("select key, value from system_config where key in ('ai_active_provider','ai_api_key','ai_model')"),
    getSystemPrompt(),
  ]);
  const map = Object.fromEntries(cfg.rows.map(r => [r.key, r.value]));

  if (!map['ai_api_key']) {
    return res.status(503).json({ error: 'El Chat IA no está configurado. Contacta al administrador.' });
  }

  const provider = map['ai_active_provider'] || 'groq';
  const apiKey   = map['ai_api_key'];
  const model    = map['ai_model'] || defaultModel(provider);

  const messages = [
    { role: 'system', content: systemPrompt },
    ...history.slice(-10),
    { role: 'user', content: message.trim() },
  ];

  try {
    let rawText;
    if (provider === 'anthropic') {
      const r = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: { 'x-api-key': apiKey, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
        body: JSON.stringify({
          model,
          messages: messages.filter(m => m.role !== 'system'),
          system: systemPrompt,
          max_tokens: 1024,
        }),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || 'Error de Anthropic');
      rawText = d.content?.[0]?.text;
    } else {
      const urls = {
        groq:     'https://api.groq.com/openai/v1/chat/completions',
        openai:   'https://api.openai.com/v1/chat/completions',
        deepseek: 'https://api.deepseek.com/v1/chat/completions',
      };
      const r = await fetch(urls[provider] || urls.groq, {
        method: 'POST',
        headers: { Authorization: `Bearer ${apiKey}`, 'content-type': 'application/json' },
        body: JSON.stringify({ model, messages, max_tokens: 1024, temperature: 0.7 }),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || 'Error del proveedor');
      rawText = d.choices?.[0]?.message?.content;
    }

    if (!rawText) throw new Error('Respuesta vacía del proveedor');

    const needsLawyer = rawText.includes('[NECESITA_ABOGADO: SI]')
      ? true
      : rawText.includes('[NECESITA_ABOGADO: NO]')
      ? false
      : null;

    const specialtyMatch = rawText.match(/\[ESPECIALIDAD: ([^\]]+)\]/);
    const specialty = specialtyMatch ? specialtyMatch[1].trim() : null;

    const cleanText = rawText
      .replace(/\[NECESITA_ABOGADO: (SI|NO)\]/g, '')
      .replace(/\[ESPECIALIDAD: [^\]]+\]/g, '')
      .trim();

    res.json({ response: cleanText, needs_lawyer: needsLawyer, specialty });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

function defaultModel(provider) {
  const m = { groq: 'llama-3.3-70b-versatile', openai: 'gpt-4o-mini', deepseek: 'deepseek-chat', anthropic: 'claude-3-5-haiku-20241022' };
  return m[provider] || 'llama-3.3-70b-versatile';
}

// POST /api/ai-chat/recommendations  — documentos requeridos según resumen de consulta
router.post('/recommendations', requireAuth, async (req, res) => {
  const { summary } = req.body;
  if (!summary?.trim()) return res.status(400).json({ error: 'summary requerido' });

  const cfg = await db.query(
    "select key, value from system_config where key in ('ai_active_provider','ai_api_key','ai_model')"
  );
  const map = Object.fromEntries(cfg.rows.map(r => [r.key, r.value]));

  if (!map['ai_api_key']) {
    return res.status(503).json({ error: 'El Chat IA no está configurado.' });
  }

  const provider = map['ai_active_provider'] || 'groq';
  const apiKey   = map['ai_api_key'];
  const model    = map['ai_model'] || defaultModel(provider);

  const prompt = `Eres un experto en trámites legales de Honduras. Analiza esta situación y lista los documentos necesarios.

SITUACIÓN: ${summary.trim()}

Responde ÚNICAMENTE con JSON válido (sin markdown). Formato exacto:
{"documents":[{"name":"Nombre del documento","description":"Para qué sirve en este trámite","institution":"Institución hondureña que lo emite","address":"Dirección en Tegucigalpa, Honduras","maps_query":"búsqueda Google Maps"}]}

Incluye 3 a 6 documentos relevantes. Usa instituciones reales de Honduras (Registro Civil, TSE, Poder Judicial, DGRH, etc.).`;

  const messages = [{ role: 'user', content: prompt }];

  try {
    let rawText;
    if (provider === 'anthropic') {
      const r = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: { 'x-api-key': apiKey, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
        body: JSON.stringify({ model, messages, max_tokens: 1024 }),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || 'Error de Anthropic');
      rawText = d.content?.[0]?.text;
    } else {
      const urls = { groq: 'https://api.groq.com/openai/v1/chat/completions', openai: 'https://api.openai.com/v1/chat/completions', deepseek: 'https://api.deepseek.com/v1/chat/completions' };
      const body = { model, messages, max_tokens: 1024, temperature: 0.3 };
      if (provider === 'groq' || provider === 'openai') body.response_format = { type: 'json_object' };
      const r = await fetch(urls[provider] || urls.groq, {
        method: 'POST',
        headers: { Authorization: `Bearer ${apiKey}`, 'content-type': 'application/json' },
        body: JSON.stringify(body),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || 'Error del proveedor');
      rawText = d.choices?.[0]?.message?.content;
    }

    if (!rawText) throw new Error('Respuesta vacía del proveedor');

    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error('Formato de respuesta inválido');

    const parsed = JSON.parse(jsonMatch[0]);
    res.json({ documents: Array.isArray(parsed.documents) ? parsed.documents : [] });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// POST /api/ai-chat/plan  — genera plan de acción estructurado para un trámite
router.post('/plan', requireAuth, async (req, res) => {
  const { summary } = req.body;
  if (!summary?.trim()) return res.status(400).json({ error: 'summary requerido' });

  const cfg = await db.query(
    "select key, value from system_config where key in ('ai_active_provider','ai_api_key','ai_model')"
  );
  const map = Object.fromEntries(cfg.rows.map(r => [r.key, r.value]));
  if (!map['ai_api_key']) return res.status(503).json({ error: 'El Chat IA no está configurado.' });

  const provider = map['ai_active_provider'] || 'groq';
  const apiKey   = map['ai_api_key'];
  const model    = map['ai_model'] || defaultModel(provider);

  const prompt = `Eres un experto en trámites legales de Honduras. Crea un plan de acción paso a paso.

SITUACIÓN: ${summary.trim()}

Responde ÚNICAMENTE con JSON válido (sin markdown). Formato exacto:
{"title":"Nombre corto del proceso legal","steps":[{"order":1,"title":"Título del paso","description":"Descripción breve de la fase"}]}

Genera entre 3 y 5 pasos secuenciales prácticos para Honduras. Solo el JSON.`;

  const messages = [{ role: 'user', content: prompt }];

  try {
    let rawText;
    if (provider === 'anthropic') {
      const r = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: { 'x-api-key': apiKey, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
        body: JSON.stringify({ model, messages, max_tokens: 800 }),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || 'Error de Anthropic');
      rawText = d.content?.[0]?.text;
    } else {
      const urls = { groq: 'https://api.groq.com/openai/v1/chat/completions', openai: 'https://api.openai.com/v1/chat/completions', deepseek: 'https://api.deepseek.com/v1/chat/completions' };
      const body = { model, messages, max_tokens: 800, temperature: 0.3 };
      if (provider === 'groq' || provider === 'openai') body.response_format = { type: 'json_object' };
      const r = await fetch(urls[provider] || urls.groq, {
        method: 'POST',
        headers: { Authorization: `Bearer ${apiKey}`, 'content-type': 'application/json' },
        body: JSON.stringify(body),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || 'Error del proveedor');
      rawText = d.choices?.[0]?.message?.content;
    }

    if (!rawText) throw new Error('Respuesta vacía');
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error('Formato inválido');
    const parsed = JSON.parse(jsonMatch[0]);
    res.json({ title: parsed.title || 'Plan legal', steps: Array.isArray(parsed.steps) ? parsed.steps : [] });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/ai-chat/sessions  — historial de sesiones del usuario
router.get('/sessions', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select id, title, needs_lawyer, created_at, updated_at
     from ai_chat_sessions
     where user_id = $1
     order by updated_at desc`,
    [req.user.id]
  );
  res.json(rows);
});

// POST /api/ai-chat/sessions  — crear nueva sesión
router.post('/sessions', requireAuth, async (req, res) => {
  const { title } = req.body;
  const { rows } = await db.query(
    `insert into ai_chat_sessions (user_id, title)
     values ($1, $2) returning *`,
    [req.user.id, title || 'Nueva consulta']
  );
  res.status(201).json(rows[0]);
});

// GET /api/ai-chat/sessions/:id/messages
router.get('/sessions/:id/messages', requireAuth, async (req, res) => {
  const session = await db.query(
    'select id from ai_chat_sessions where id = $1 and user_id = $2',
    [req.params.id, req.user.id]
  );
  if (!session.rows[0]) return res.status(404).json({ error: 'Sesión no encontrada' });

  const { rows } = await db.query(
    'select * from ai_chat_messages where session_id = $1 order by created_at asc',
    [req.params.id]
  );
  res.json(rows);
});

// POST /api/ai-chat/sessions/:id/messages  — guardar mensaje (user o assistant)
router.post('/sessions/:id/messages', requireAuth, async (req, res) => {
  const { role, content } = req.body;
  if (!role || !content) return res.status(400).json({ error: 'role y content requeridos' });
  if (!['user', 'assistant'].includes(role)) {
    return res.status(400).json({ error: 'role debe ser user o assistant' });
  }

  const session = await db.query(
    'select id from ai_chat_sessions where id = $1 and user_id = $2',
    [req.params.id, req.user.id]
  );
  if (!session.rows[0]) return res.status(404).json({ error: 'Sesión no encontrada' });

  const { rows } = await db.query(
    'insert into ai_chat_messages (session_id, role, content) values ($1, $2, $3) returning *',
    [req.params.id, role, content]
  );

  // Actualiza timestamp de la sesión
  await db.query(
    'update ai_chat_sessions set updated_at = now() where id = $1',
    [req.params.id]
  );

  res.status(201).json(rows[0]);
});

// PUT /api/ai-chat/sessions/:id  — actualizar título o resultado needs_lawyer
router.put('/sessions/:id', requireAuth, async (req, res) => {
  const { title, needs_lawyer } = req.body;
  const { rows } = await db.query(
    `update ai_chat_sessions
     set title        = coalesce($1, title),
         needs_lawyer = coalesce($2, needs_lawyer),
         updated_at   = now()
     where id = $3 and user_id = $4
     returning *`,
    [title, needs_lawyer ?? null, req.params.id, req.user.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Sesión no encontrada' });
  res.json(rows[0]);
});

// DELETE /api/ai-chat/sessions/:id
router.delete('/sessions/:id', requireAuth, async (req, res) => {
  const { rowCount } = await db.query(
    'delete from ai_chat_sessions where id = $1 and user_id = $2',
    [req.params.id, req.user.id]
  );
  if (!rowCount) return res.status(404).json({ error: 'Sesión no encontrada' });
  res.json({ message: 'Sesión eliminada' });
});

module.exports = router;
