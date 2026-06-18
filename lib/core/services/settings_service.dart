import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de configuración persistente usando SharedPreferences.
/// Gestiona la configuración de proveedores IA y el PIN de administrador.
class SettingsService {
  // --- Claves base ---
  static const String _activeProvider = 'active_ai_provider';
  static const String _adminPin = 'admin_pin';
  static const String _defaultAdminPin = '';

  // Sub-claves por proveedor (prefijo + providerKey)
  static String _enabledKey(String pk) => 'provider_${pk}_enabled';
  static String _apiKeyKey(String pk) => 'provider_${pk}_api_key';
  static String _modelKey(String pk) => 'provider_${pk}_model';

  // ------------------------------------------------------------------ //
  //  Configuración de proveedores IA
  // ------------------------------------------------------------------ //

  /// Guarda la configuración completa de un proveedor.
  Future<void> saveProviderConfig(
    String providerKey, {
    required bool enabled,
    required String apiKey,
    required String model,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_enabledKey(providerKey), enabled),
      prefs.setString(_apiKeyKey(providerKey), apiKey),
      prefs.setString(_modelKey(providerKey), model),
    ]);
  }

  /// Retorna la configuración de un proveedor como mapa.
  /// Claves: 'enabled' (bool), 'apiKey' (String), 'model' (String).
  Future<Map<String, dynamic>> getProviderConfig(String providerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_enabledKey(providerKey)) ?? false,
      'apiKey': prefs.getString(_apiKeyKey(providerKey)) ?? '',
      'model': prefs.getString(_modelKey(providerKey)) ?? '',
    };
  }

  /// Retorna la clave del proveedor activo, o null si no hay ninguno.
  Future<String?> getActiveProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProvider);
  }

  /// Establece el proveedor activo.
  Future<void> setActiveProvider(String providerKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProvider, providerKey);
  }

  /// Indica si un proveedor está habilitado.
  Future<bool> isProviderEnabled(String providerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey(providerKey)) ?? false;
  }

  /// Retorna la API Key de un proveedor, o null si no está configurada.
  Future<String?> getApiKey(String providerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_apiKeyKey(providerKey));
    if (key == null || key.isEmpty) return null;
    return key;
  }

  /// Retorna el modelo configurado para un proveedor, o null si no está.
  Future<String?> getModel(String providerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final model = prefs.getString(_modelKey(providerKey));
    if (model == null || model.isEmpty) return null;
    return model;
  }

  // ------------------------------------------------------------------ //
  //  PIN de administrador
  // ------------------------------------------------------------------ //

  /// Guarda el PIN de administrador.
  Future<void> saveAdminPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminPin, pin);
  }

  /// Retorna el PIN guardado. Si no hay ninguno, retorna el PIN por defecto.
  Future<String?> getAdminPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminPin) ?? _defaultAdminPin;
  }

  /// Verifica si el PIN ingresado coincide con el guardado.
  /// Si no hay PIN guardado, compara contra el PIN por defecto ('1234').
  Future<bool> verifyAdminPin(String pin) async {
    final stored = await getAdminPin();
    return stored == pin;
  }
}
