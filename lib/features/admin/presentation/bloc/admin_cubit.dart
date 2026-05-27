import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/features/admin/data/datasources/admin_local_datasource.dart';
import 'package:juris_honoris/features/admin/domain/entities/ai_provider_config.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminLocalDatasource _datasource;

  AdminCubit({required AdminLocalDatasource datasource})
      : _datasource = datasource,
        super(AdminInitial());

  Future<void> loadProviders() async {
    emit(AdminLoading());
    try {
      final providers = await _datasource.loadAllProviderConfigs();
      emit(AdminLoaded(providers));
    } catch (e) {
      emit(AdminError('Error al cargar proveedores: $e'));
    }
  }

  Future<void> toggleProvider(String key, bool enabled) async {
    final current = state;
    if (current is! AdminLoaded) return;

    final updated = current.providers.map((p) {
      if (p.key == key) {
        // Si se deshabilita y era el activo, quitar estado activo
        final isActive = enabled ? p.isActive : false;
        return p.copyWith(isEnabled: enabled, isActive: isActive);
      }
      return p;
    }).toList();

    emit(AdminLoaded(updated));

    // Si el proveedor desactivado era el activo, limpiar en prefs
    final wasActive =
        current.providers.firstWhere((p) => p.key == key).isActive;
    if (!enabled && wasActive) {
      await _datasource.setActiveProvider('');
    }
  }

  Future<void> updateApiKey(String key, String apiKey) async {
    final current = state;
    if (current is! AdminLoaded) return;

    final updated = current.providers.map((p) {
      if (p.key == key) return p.copyWith(apiKey: apiKey);
      return p;
    }).toList();

    emit(AdminLoaded(updated));
  }

  Future<void> updateModel(String key, String model) async {
    final current = state;
    if (current is! AdminLoaded) return;

    final updated = current.providers.map((p) {
      if (p.key == key) return p.copyWith(model: model);
      return p;
    }).toList();

    emit(AdminLoaded(updated));
  }

  Future<void> setActiveProvider(String key) async {
    final current = state;
    if (current is! AdminLoaded) return;

    final provider = current.providers.firstWhere(
      (p) => p.key == key,
      orElse: () => current.providers.first,
    );

    if (!provider.hasApiKey) {
      emit(AdminError('Ingresa una API key primero'));
      // Restaurar estado loaded para no bloquear UI
      emit(AdminLoaded(current.providers));
      return;
    }

    final updated = current.providers.map((p) {
      return p.copyWith(isActive: p.key == key);
    }).toList();

    await _datasource.setActiveProvider(key);
    emit(AdminLoaded(updated));
  }

  Future<void> saveAllChanges(List<AIProviderConfig> configs) async {
    final current = state;
    if (current is! AdminLoaded) return;

    emit(AdminLoading());
    try {
      for (final config in configs) {
        await _datasource.saveProviderConfig(config);
      }

      // Guardar el proveedor activo
      final activeProvider = configs.where((p) => p.isActive).firstOrNull;
      if (activeProvider != null) {
        await _datasource.setActiveProvider(activeProvider.key);
      }

      emit(AdminSaved(configs));
      // Volver a loaded con los datos guardados
      emit(AdminLoaded(configs));
    } catch (e) {
      emit(AdminError('Error al guardar: $e'));
      emit(AdminLoaded(current.providers));
    }
  }

  AIProviderConfig? getProvider(String key) {
    final current = state;
    if (current is! AdminLoaded) return null;
    try {
      return current.providers.firstWhere((p) => p.key == key);
    } catch (_) {
      return null;
    }
  }

  bool get hasActiveConfiguredProvider {
    final current = state;
    if (current is! AdminLoaded) return false;
    return current.providers.any((p) => p.isActive && p.hasApiKey);
  }

  List<AIProviderConfig> get currentProviders {
    final current = state;
    if (current is AdminLoaded) return current.providers;
    if (current is AdminSaved) return current.providers;
    return [];
  }
}
