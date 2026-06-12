part of 'documents_cubit.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();
  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {
  const DocumentsInitial();
}

class DocumentsLoading extends DocumentsState {
  const DocumentsLoading();
}

class DocumentsUploading extends DocumentsState {
  final List<DocumentData> docs;
  const DocumentsUploading(this.docs);
  @override
  List<Object?> get props => [docs];
}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentData> docs;
  const DocumentsLoaded(this.docs);
  @override
  List<Object?> get props => [docs];
}

class DocumentsError extends DocumentsState {
  final String message;
  const DocumentsError(this.message);
  @override
  List<Object?> get props => [message];
}
