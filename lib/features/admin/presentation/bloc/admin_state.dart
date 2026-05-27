part of 'admin_cubit.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<AIProviderConfig> providers;

  AdminLoaded(this.providers);

  AdminLoaded copyWith({List<AIProviderConfig>? providers}) {
    return AdminLoaded(providers ?? this.providers);
  }
}

class AdminSaved extends AdminState {
  final List<AIProviderConfig> providers;

  AdminSaved(this.providers);
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);
}
