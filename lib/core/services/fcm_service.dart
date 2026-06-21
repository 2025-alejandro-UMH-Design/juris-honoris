import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:juris_honoris/core/constants/api_config.dart';

class FcmService {
  static Future<void> registerToken(Dio dio) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token != null) {
        await dio.put('${ApiConfig.auth}/me', data: {'fcm_token': token});
      }

      messaging.onTokenRefresh.listen((newToken) {
        dio.put('${ApiConfig.auth}/me', data: {'fcm_token': newToken});
      });
    } catch (_) {
      // FCM no es crítico — no rompe el flujo si falla
    }
  }
}
