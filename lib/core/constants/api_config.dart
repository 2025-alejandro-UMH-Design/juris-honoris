class ApiConfig {
  ApiConfig._();

  // URL base inyectada al compilar con --dart-define=API_BASE_URL=...
  // Si no se pasa el define, usa el servidor de producción en Railway.
  //
  // Para producción (APK para distribuir):
  //   flutter build apk
  //   (usa la URL de Railway por defecto — no necesita nada extra)
  //
  // Para desarrollo en emulador Android (apunta al backend local):
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  //
  // Para dispositivo físico (misma red Wi-Fi):
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.94:3000/api
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-production-192ce.up.railway.app/api',
  );

  // Endpoints
  static const auth          = '$baseUrl/auth';
  static const lawyers       = '$baseUrl/lawyers';
  static const cases         = '$baseUrl/cases';
  static const requests      = '$baseUrl/requests';
  static const chat          = '$baseUrl/chat';
  static const aiChat        = '$baseUrl/ai-chat';
  static const reviews       = '$baseUrl/reviews';
  static const notifications = '$baseUrl/notifications';
  static const admin         = '$baseUrl/admin';
}
