part of 'recommendations_cubit.dart';

abstract class RecommendationsState extends Equatable {
  const RecommendationsState();
  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {
  const RecommendationsInitial();
}

class RecommendationsLoading extends RecommendationsState {
  const RecommendationsLoading();
}

class RecommendationsLoaded extends RecommendationsState {
  final List<RequiredDoc> docs;
  const RecommendationsLoaded(this.docs);
  @override
  List<Object?> get props => [docs];
}

class RecommendationsError extends RecommendationsState {
  final String message;
  const RecommendationsError(this.message);
  @override
  List<Object?> get props => [message];
}
