import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juris_honoris/features/admin/domain/entities/ai_provider_config.dart';

class AdminLocalDatasource {
  final SharedPreferences _prefs;

  static const _pinKey = 'admin_pin';
  static const _providersKey = 'ai_providers';
  static const _defaultPin = '1234';

  AdminLocalDatasource({required SharedPreferences prefs}) : _prefs = prefs;

  Future<bool> verifyPin(String pin) async {
    final stored = _prefs.getString(_pinKey) ?? _defaultPin;
    return pin == stored;
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
  }

  Future<List<AIProviderConfig>> loadProviders() async {
    final json = _prefs.getString(_providersKey);
    if (json == null) return List.from(defaultProviders);
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((j) => AIProviderConfig.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List.from(defaultProviders);
    }
  }

  Future<void> saveProviders(List<AIProviderConfig> providers) async {
    final json = jsonEncode(providers.map((p) => p.toJson()).toList());
    await _prefs.setString(_providersKey, json);
  }
}
