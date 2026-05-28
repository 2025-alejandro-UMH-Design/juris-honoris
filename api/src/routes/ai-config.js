const router = require('express').Router();
const db     = require('../db');
const { requireAuth, requireRole } = require('../middleware/auth');
const guard  = [requireAuth, requireRole('admin')];

const PROVIDERS = {
  groq:      { baseUrl: 'https://api.groq.com/openai/v1/chat/completions',         format: 'openai' },
  openai:    { baseUrl: 'https://api.openai.com/v1/chat/completions',              format: 'openai' },
  deepseek:  { baseUrl: 'https://api.deepseek.com/v1/chat/completions',            format: 'openai' },
  anthropic: { baseUrl: 'https://api.anthropic.com/v1/messages',                   format: 'anthropic' },
};

// GET /api/admin/ai-config
router.get('/', ...guard, async (req, res) => {
  const { rows } = await db.query('select key, value from system_config where key like $1', ['ai_%']);
  const map = Object.fromEntries(rows.map(r => [r.key, r.value]));
  res.json({
    active_provider: map['ai_active_provider'] || 'groq',
    api_key:         map['ai_api_key'] ? '••••••••' : '',   // nunca exponer la clave real
    model:           map['ai_model'] || '',
  });
});

// PUT /api/admin/ai-config
router.put('/', ...guard, async (req, res) => {
  const { active_provider, api_key, model } = req.body;
  if (!active_provider) return res.status(400).json({ error: 'active_provider requerido' });

  const upsert = (key, value) => db.query(
    `insert into system_config (key, value, updated_at) values ($1, $2, now())
     on conflict (key) do update set value = $2, updated_at = now()`,
    [key, value]
  );

  await upsert('ai_active_provider', active_provider);
  if (model) await upsert('ai_model', model);
  // Solo actualiza la clave si no es el placeholder
  if (api_key && api_key !== '••••••••') await upsert('ai_api_key', api_key);

  res.json({ message: 'Configuración guardada' });
});

// POST /api/admin/ai-config/test  — prueba la conexión
router.post('/test', ...guard, async (req, res) => {
  const { active_provider, api_key, model } = req.body;
  const provider = PROVIDERS[active_provider];
  if (!provider) return res.status(400).json({ error: 'Proveedor no soportado' });

  const key = (api_key && api_key !== '••••••••')
    ? api_key
    : (await db.query("select value from system_config where key = 'ai_api_key'")).rows[0]?.value;

  if (!key) return res.status(400).json({ error: 'No hay API Key configurada' });

  const testMsg = [{ role: 'user', content: 'Responde solo con "ok"' }];

  try {
    let raw;
    if (provider.format === 'anthropic') {
      const r = await fetch(provider.baseUrl, {
        method: 'POST',
        headers: { 'x-api-key': key, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
        body: JSON.stringify({ model: model || 'claude-3-5-haiku-20241022', messages: testMsg, max_tokens: 20 }),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || JSON.stringify(d));
      raw = d.content?.[0]?.text || 'ok';
    } else {
      const r = await fetch(provider.baseUrl, {
        method: 'POST',
        headers: { Authorization: `Bearer ${key}`, 'content-type': 'application/json' },
        body: JSON.stringify({ model: model || 'llama-3.3-70b-versatile', messages: testMsg, max_tokens: 20 }),
      });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error?.message || JSON.stringify(d));
      raw = d.choices?.[0]?.message?.content || 'ok';
    }
    res.json({ ok: true, response: raw.trim().slice(0, 80) });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

module.exports = router;
