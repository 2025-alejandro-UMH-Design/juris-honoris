const admin = require('firebase-admin');

let _ready = false;

function init() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!raw) {
    console.warn('⚠  FIREBASE_SERVICE_ACCOUNT no configurado — push notifications desactivadas');
    return;
  }
  try {
    admin.initializeApp({ credential: admin.credential.cert(JSON.parse(raw)) });
    _ready = true;
    console.log('✓ Firebase Admin inicializado');
  } catch (e) {
    console.warn('⚠  Firebase Admin: error al inicializar —', e.message);
  }
}

async function send(token, title, body) {
  if (!_ready || !token) return;
  try {
    await admin.messaging().send({ token, notification: { title, body } });
  } catch (_) {
    // token puede estar vencido — ignorar
  }
}

module.exports = { init, send };
