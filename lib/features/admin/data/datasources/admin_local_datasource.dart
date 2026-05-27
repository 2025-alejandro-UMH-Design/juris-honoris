import 'package:shared_preferences/shared_preferences.dart';

import 'package:juris_honoris/features/admin/domain/entities/ai_provider_config.dart';

class AdminLocalDatasource {
  final SharedPreferences _prefs;

  static const String _activProviderKey = 'active_provider';
  static const String _adminPinKey = 'admin_pin';
  static const String _defaultPin = '1234';

  static String _enabledKey(String key) => 'provider_${key}_enabled';
  static String _apiKeyKey(String key) => 'provider_${key}_apikey';
  static String _modelKey(String key) => 'provider_${key}_model';

  AdminLocalDatasource({required SharedPreferences prefs}) : _prefs = prefs;

  Future<List<AIProviderConfig>> loadAllProviderConfigs() async {
    final defaults = AIProviderConfig.defaults;
    final activeProviderKey = _prefs.getString(_activProviderKey) ?? '';

    return defaults.map((provider) {
      final isEnabled =
          _prefs.getBool(_enabledKey(provider.key)) ?? provider.isEnabled;
      final apiKey = _prefs.getString(_apiKeyKey(provider.key)) ?? provider.apiKey;
      final model = _prefs.getString(_modelKey(provider.key)) ?? provider.model;
      final isActive = activeProviderKey == provider.key;

      return provider.copyWith(
        isEnabled: isEnabled,
        apiKey: apiKey,
        model: model,
        isActive: isActive,
      );
    }).toList();
  }

  Future<void> saveProviderConfig(AIProviderConfig config) async {
    await _prefs.setBool(_enabledKey(config.key), config.isEnabled);
    await _prefs.setString(_apiKeyKey(config.key), config.apiKey);
    await _prefs.setString(_modelKey(config.key), config.model);
  }

  Future<void> setActiveProvider(String providerKey) async {
    await _prefs.setString(_activProviderKey, providerKey);
  }

  Future<void> saveAdminPin(String pin) async {
    await _prefs.setString(_adminPinKey, pin);
  }

  Future<String> getAdminPin() async {
    return _prefs.getString(_adminPinKey) ?? _defaultPin;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await getAdminPin();
    return storedPin == pin;
  }

  /// Retorna la clave del proveedor activo, o null si ninguno está configurado.
  Future<String?> getActiveProviderKey() async {
    return _prefs.getString(_activProviderKey);
  }
}
