const multer = require('multer');

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

const memoryStorage = multer.memoryStorage();

const uploadCase   = multer({ storage: memoryStorage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });
const uploadLawyer = multer({ storage: memoryStorage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });
const uploadAvatar = multer({ storage: memoryStorage, fileFilter, limits: { fileSize: 2  * 1024 * 1024 } });

module.exports = { uploadCase, uploadLawyer, uploadAvatar };
