class ApiConfig {
  ApiConfig._();

  // ── Cambiar según el entorno ───────────────────────────────
  //
  // Flutter web (DevicePreview en Chrome):
  //   static const _host = 'localhost';
  //
  // Android emulator:
  //   static const _host = '10.0.2.2';
  //
  // Dispositivo físico (misma red Wi-Fi que la PC):
  //   static const _host = '192.168.1.94';
  //
  static const _host = '192.168.1.94';
  static const _port = '3000';

  static const baseUrl = 'http://$_host:$_port/api';

  // Endpoints
  static const auth         = '$baseUrl/auth';
  static const lawyers      = '$baseUrl/lawyers';
  static const cases        = '$baseUrl/cases';
  static const requests     = '$baseUrl/requests';
  static const chat         = '$baseUrl/chat';
  static const aiChat       = '$baseUrl/ai-chat';
  static const reviews      = '$baseUrl/reviews';
  static const notifications = '$baseUrl/notifications';
  static const admin        = '$baseUrl/admin';
}
