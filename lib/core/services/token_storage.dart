import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final SharedPreferences _prefs;
  static const _key = 'jh_jwt_token';

  TokenStorage(this._prefs);

  String? get token => _prefs.getString(_key);

  Future<void> save(String token) => _prefs.setString(_key, token);

  Future<void> clear() => _prefs.remove(_key);
}
