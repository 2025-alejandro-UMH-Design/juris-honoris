import 'package:shared_preferences/shared_preferences.dart';

/// Claves de SharedPreferences para la configuración de proveedores IA.
/// Formato de claves: ai_{providerKey}_{campo}
class AIPrefsKeys {
  AIPrefsKeys._();

  static const String activeProvider = 'ai_active_provider';

  static String apiKey(String providerKey) => 'ai_${providerKey}_api_key';
  static String model(String providerKey) => 'ai_${providerKey}_model';
  static String enabled(String providerKey) => 'ai_${providerKey}_enabled';
}

class AILocalDatasource {
  final SharedPreferences _prefs;

  AILocalDatasource(this._prefs);

  /// Retorna el key del proveedor activo (ej. 'groq', 'openai').
  Future<String?> getActiveProviderKey() async {
    return _prefs.getString(AIPrefsKeys.activeProvider);
  }

  /// Retorna la API key almacenada para el proveedor dado.
  Future<String?> getApiKey(String providerKey) async {
    return _prefs.getString(AIPrefsKeys.apiKey(providerKey));
  }

  /// Retorna el modelo configurado para el proveedor, o null si no está configurado.
  Future<String?> getModel(String providerKey) async {
    return _prefs.getString(AIPrefsKeys.model(providerKey));
  }

  /// Retorna true si el proveedor está marcado como activo/habilitado.
  Future<bool> isProviderEnabled(String providerKey) async {
    return _prefs.getBool(AIPrefsKeys.enabled(providerKey)) ?? false;
  }

  /// Retorna true si hay al menos un proveedor configurado con API key y habilitado.
  Future<bool> isAnyProviderConfigured() async {
    final activeKey = await getActiveProviderKey();
    if (activeKey == null || activeKey.isEmpty) return false;

    final apiKey = await getApiKey(activeKey);
    if (apiKey == null || apiKey.isEmpty) return false;

    final enabled = await isProviderEnabled(activeKey);
    return enabled;
  }
}
