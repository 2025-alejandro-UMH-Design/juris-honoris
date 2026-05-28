const multer = require('multer');
const path   = require('path');
const fs     = require('fs');

function diskStorage(subfolder) {
  return multer.diskStorage({
    destination(req, _file, cb) {
      const id  = req.params.caseId || req.params.lawyerId || req.user.id;
      const dir = path.join(__dirname, '../../uploads', subfolder, id);
      fs.mkdirSync(dir, { recursive: true });
      cb(null, dir);
    },
    filename(_req, file, cb) {
      const ext  = path.extname(file.originalname);
      const base = path.basename(file.originalname, ext)
        .replace(/[^a-zA-Z0-9_-]/g, '_')
        .slice(0, 60);
      cb(null, `${Date.now()}_${base}${ext}`);
    },
  });
}

const ALLOWED_MIME = [
  'image/jpeg', 'image/png', 'image/webp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
];

function fileFilter(_req, file, cb) {
  if (ALLOWED_MIME.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Tipo de archivo no permitido: ${file.mimetype}`));
  }
}

const uploadCase   = multer({ storage: diskStorage('cases'),   fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });
const uploadLawyer = multer({ storage: diskStorage('lawyers'), fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });
const uploadAvatar = multer({ storage: diskStorage('avatars'), fileFilter, limits: { fileSize: 2  * 1024 * 1024 } });

module.exports = { uploadCase, uploadLawyer, uploadAvatar };
