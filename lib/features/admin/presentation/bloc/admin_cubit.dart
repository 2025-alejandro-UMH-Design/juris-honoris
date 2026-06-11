import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/features/admin/data/datasources/admin_local_datasource.dart';
import 'package:juris_honoris/features/admin/domain/entities/ai_provider_config.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminLocalDatasource _datasource;

  AdminCubit({required AdminLocalDatasource datasource})
      : _datasource = datasource,
        super(const AdminLoading());

  List<AIProviderConfig> get currentProviders =>
      state is AdminLoaded ? (state as AdminLoaded).providers :
      state is AdminSaved ? (state as AdminSaved).providers : [];

  Future<void> loadProviders() async {
    emit(const AdminLoading());
    try {
      final providers = await _datasource.loadProviders();
      emit(AdminLoaded(providers));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  void toggleProvider(String key, bool enabled) {
    final providers = currentProviders.map((p) {
      if (p.key == key) return p.copyWith(isEnabled: enabled);
      return p;
    }).toList();
    emit(AdminLoaded(providers));
  }

  void updateModel(String key, String model) {
    final providers = currentProviders.map((p) {
      if (p.key == key) return p.copyWith(model: model);
      return p;
    }).toList();
    emit(AdminLoaded(providers));
  }

  void updateApiKey(String key, String apiKey) {
    final providers = currentProviders.map((p) {
      if (p.key == key) return p.copyWith(apiKey: apiKey);
      return p;
    }).toList();
    emit(AdminLoaded(providers));
  }

  void setActiveProvider(String key) {
    final providers = currentProviders.map((p) {
      return p.copyWith(isActive: p.key == key);
    }).toList();
    emit(AdminLoaded(providers));
  }

  Future<void> saveAllChanges(List<AIProviderConfig> providers) async {
    try {
      await _datasource.saveProviders(providers);
      emit(AdminSaved(providers));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
