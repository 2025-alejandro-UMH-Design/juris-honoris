const router     = require('express').Router();
const cloudinary = require('../cloudinary');
const { requireAuth } = require('../middleware/auth');
const { uploadCase }  = require('../middleware/upload');

function toCloudinary(buffer, folder, type) {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream(
      { folder, resource_type: type, use_filename: false },
      (err, r) => err ? reject(err) : resolve(r)
    ).end(buffer);
  });
}

// POST /api/upload/temp — sube cualquier archivo y devuelve su URL de Cloudinary
// Usado por el formulario de solicitudes y el chat para adjuntar archivos
router.post('/temp', requireAuth, uploadCase.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Archivo requerido' });
  const isRaw = req.file.mimetype === 'application/pdf' ||
                req.file.mimetype.includes('word') ||
                req.file.mimetype.includes('document');
  const result = await toCloudinary(req.file.buffer, 'juris-honoris/attachments', isRaw ? 'raw' : 'image');
  res.json({ url: result.secure_url, name: req.file.originalname });
});

module.exports = router;
