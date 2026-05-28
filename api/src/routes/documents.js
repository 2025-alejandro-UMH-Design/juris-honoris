const router = require('express').Router({ mergeParams: true });
const path   = require('path');
const fs     = require('fs');
const db     = require('../db');
const { requireAuth }   = require('../middleware/auth');
const { uploadCase }    = require('../middleware/upload');

// GET /api/cases/:caseId/documents
router.get('/', requireAuth, async (req, res) => {
  // Verifica que el caso pertenezca al usuario o sea su abogado
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

// POST /api/cases/:caseId/documents  — subir archivo
router.post('/', requireAuth, uploadCase.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Archivo requerido' });

  const caseRow = await db.query('select client_id from cases where id = $1', [req.params.caseId]);
  if (!caseRow.rows[0]) return res.status(404).json({ error: 'Caso no encontrado' });
  if (caseRow.rows[0].client_id !== req.user.id && req.user.role !== 'lawyer') {
    return res.status(403).json({ error: 'Sin acceso a este caso' });
  }

  const relativePath = `uploads/cases/${req.params.caseId}/${req.file.filename}`;

  const { rows } = await db.query(
    `insert into case_documents (case_id, uploaded_by, name, file_path, file_type, file_size_bytes)
     values ($1, $2, $3, $4, $5, $6) returning *`,
    [
      req.params.caseId,
      req.user.id,
      req.body.name || req.file.originalname,
      relativePath,
      req.file.mimetype,
      req.file.size,
    ]
  );
  res.status(201).json(rows[0]);
});

// GET /api/cases/:caseId/documents/:docId/download
router.get('/:docId/download', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select cd.*, c.client_id, c.lawyer_id
     from case_documents cd
     join cases c on c.id = cd.case_id
     where cd.id = $1 and cd.case_id = $2`,
    [req.params.docId, req.params.caseId]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Documento no encontrado' });

  const doc = rows[0];
  if (req.user.id !== doc.client_id && req.user.id !== doc.lawyer_id) {
    return res.status(403).json({ error: 'Sin acceso a este documento' });
  }

  const absPath = path.join(__dirname, '../../', doc.file_path);
  if (!fs.existsSync(absPath)) {
    return res.status(404).json({ error: 'Archivo no encontrado en disco' });
  }

  res.download(absPath, doc.name);
});

// DELETE /api/cases/:caseId/documents/:docId
router.delete('/:docId', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    `select cd.file_path, c.client_id
     from case_documents cd
     join cases c on c.id = cd.case_id
     where cd.id = $1 and cd.case_id = $2`,
    [req.params.docId, req.params.caseId]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Documento no encontrado' });
  if (rows[0].client_id !== req.user.id) {
    return res.status(403).json({ error: 'Solo el cliente puede eliminar documentos' });
  }

  await db.query('delete from case_documents where id = $1', [req.params.docId]);

  const absPath = path.join(__dirname, '../../', rows[0].file_path);
  if (fs.existsSync(absPath)) fs.unlinkSync(absPath);

  res.json({ message: 'Documento eliminado' });
});

module.exports = router;
