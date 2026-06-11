part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final List<AIProviderConfig> providers;
  const AdminLoaded(this.providers);
  @override
  List<Object?> get props => [providers];
}

class AdminSaved extends AdminState {
  final List<AIProviderConfig> providers;
  const AdminSaved(this.providers);
  @override
  List<Object?> get props => [providers];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
