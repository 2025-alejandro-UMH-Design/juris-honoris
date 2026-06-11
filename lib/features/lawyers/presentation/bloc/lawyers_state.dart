part of 'lawyers_cubit.dart';

abstract class LawyersState extends Equatable {
  const LawyersState();
  @override
  List<Object?> get props => [];
}

class LawyersInitial extends LawyersState {
  const LawyersInitial();
}

class LawyersLoading extends LawyersState {
  const LawyersLoading();
}

class LawyersLoaded extends LawyersState {
  final List<LawyerData> lawyers;
  const LawyersLoaded(this.lawyers);
  @override
  List<Object?> get props => [lawyers];
}

class LawyerProfileLoaded extends LawyersState {
  final LawyerData lawyer;
  const LawyerProfileLoaded(this.lawyer);
  @override
  List<Object?> get props => [lawyer];
}

class LawyerRequestSent extends LawyersState {
  const LawyerRequestSent();
}

class LawyersError extends LawyersState {
  final String message;
  const LawyersError(this.message);
  @override
  List<Object?> get props => [message];
}
