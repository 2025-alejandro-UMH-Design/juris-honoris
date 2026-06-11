class ApiConfig {
  ApiConfig._();

  // URL base inyectada al compilar con --dart-define=API_BASE_URL=https://tu-servidor.up.railway.app/api
  // Si no se pasa el define, usa la IP del emulador de Android Studio por defecto.
  //
  // Para producción (APK):
  //   flutter build apk --dart-define=API_BASE_URL=https://juris-honoris-api.up.railway.app/api
  //
  // Para desarrollo en emulador Android:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  //
  // Para dispositivo físico (misma red):
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.94:3000/api
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
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
