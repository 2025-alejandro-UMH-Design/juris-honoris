const router     = require('express').Router({ mergeParams: true });
const rateLimit  = require('express-rate-limit');
const db         = require('../db');
const cloudinary = require('../cloudinary');
const { requireAuth } = require('../middleware/auth');
const { uploadCase }  = require('../middleware/upload');

// S3: 30 uploads por hora por IP — protege Cloudinary y la DB
const docUploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 30,
  message: { error: 'Límite de subidas alcanzado. Intenta en una hora.' },
  standardHeaders: true,
  legacyHeaders: false,
});

function uploadToCloudinary(buffer, folder, resourceType) {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream(
      { folder, resource_type: resourceType, use_filename: false },
      (err, result) => (err ? reject(err) : resolve(result))
    ).end(buffer);
  });
}

// GET /api/cases/:caseId/documents
router.get('/', requireAuth, async (req, res) => {
  const caseRow = await db.query(
    'select client_id, lawyer_id from cases where id = $1',
    [req.params.caseId]
  );
  if (!caseRow.rows[0]) return res.status(404).json({ error: 'Caso no encontrado' });

  const { client_id, lawyer_id } = caseRow.rows[0];
  if (req.user.id !== client_id && req.user.id !== lawyer_id) {
    return res.status(403).json({ error: 'Sin acceso a este caso' });
  }

  const { rows } = await db.query(
    `select cd.*, u.full_name as uploaded_by_name
     from case_documents cd
     join users u on u.id = cd.uploaded_by
     where cd.case_id = $1
     order by cd.created_at desc`,
    [req.params.caseId]
  );
  res.json(rows);
});

// POST /api/cases/:caseId/documents  — subir archivo a Cloudinary
router.post('/', requireAuth, docUploadLimiter, uploadCase.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Archivo requerido' });

  const caseRow = await db.query('select client_id, lawyer_id from cases where id = $1', [req.params.caseId]);
  if (!caseRow.rows[0]) return res.status(404).json({ error: 'Caso no encontrado' });
  const { client_id: uploadClientId, lawyer_id: uploadLawyerId } = caseRow.rows[0];
  if (req.user.id !== uploadClientId && req.user.id !== uploadLawyerId) {
    return res.status(403).json({ error: 'Sin acceso a este caso' });
  }

  try {
    const isPdf = req.file.mimetype === 'application/pdf' ||
                  req.file.mimetype.includes('word');
    const resourceType = isPdf ? 'raw' : 'image';
    const folder = `juris-honoris/cases/${req.params.caseId}`;

    const result = await uploadToCloudinary(req.file.buffer, folder, resourceType);

    // S5: sanitiza nombre para prevenir XSS si se renderiza sin escapar
    const rawName = req.body.name || req.file.originalname || 'documento';
    const safeName = rawName.replace(/[<>"'&]/g, '').substring(0, 255).trim();

    const { rows } = await db.query(
      `insert into case_documents (case_id, uploaded_by, name, file_path, file_type, file_size_bytes)
       values ($1, $2, $3, $4, $5, $6) returning *`,
      [
        req.params.caseId,
        req.user.id,
        safeName,
        result.secure_url,
        req.file.mimetype,
        req.file.size,
      ]
    );
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: 'Error al subir el archivo: ' + e.message });
  }
});

// GET /api/cases/:caseId/documents/:docId/download  — redirige a URL de Cloudinary
router.get('/:docId/download', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select cd.file_path, c.client_id, c.lawyer_id
     from case_documents cd
     join cases c on c.id = cd.case_id
     where cd.id = $1 and cd.case_id = $2`,
    [req.params.docId, req.params.caseId]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Documento no encontrado' });
  if (req.user.id !== rows[0].client_id && req.user.id !== rows[0].lawyer_id) {
    return res.status(403).json({ error: 'Sin acceso a este documento' });
  }
  res.redirect(rows[0].file_path);
});

// DELETE /api/cases/:caseId/documents/:docId
router.delete('/:docId', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select cd.file_path, c.client_id, c.lawyer_id
     from case_documents cd
     join cases c on c.id = cd.case_id
     where cd.id = $1 and cd.case_id = $2`,
    [req.params.docId, req.params.caseId]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Documento no encontrado' });
  if (req.user.id !== rows[0].client_id && req.user.id !== rows[0].lawyer_id) {
    return res.status(403).json({ error: 'Sin acceso a este documento' });
  }

  await db.query('delete from case_documents where id = $1', [req.params.docId]);

  // Intenta eliminar de Cloudinary (best-effort)
  try {
    const url = rows[0].file_path;
    const m = url.match(/\/upload\/(?:v\d+\/)?(.+?)(\.[^./]+)?$/);
    if (m) {
      const publicId = m[1];
      await cloudinary.uploader.destroy(publicId, { resource_type: 'image' }).catch(() =>
        cloudinary.uploader.destroy(publicId, { resource_type: 'raw' })
      );
    }
  } catch (_) { /* non-critical */ }

  res.json({ message: 'Documento eliminado' });
});

module.exports = router;
