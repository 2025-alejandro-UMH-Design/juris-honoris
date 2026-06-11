part of 'cases_cubit.dart';

abstract class CasesState extends Equatable {
  const CasesState();
  @override
  List<Object?> get props => [];
}

class CasesInitial extends CasesState {
  const CasesInitial();
}

class CasesLoading extends CasesState {
  const CasesLoading();
}

class CasesLoaded extends CasesState {
  final List<TaskData> cases;
  const CasesLoaded(this.cases);
  @override
  List<Object?> get props => [cases];
}

class CaseCreated extends CasesState {
  final TaskData created;
  const CaseCreated(this.created);
  @override
  List<Object?> get props => [created];
}

class CasesError extends CasesState {
  final String message;
  const CasesError(this.message);
  @override
  List<Object?> get props => [message];
}
