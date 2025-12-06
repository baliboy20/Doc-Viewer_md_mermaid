import 'package:equatable/equatable.dart';
import '../../domain/entities/annotation.dart';

/// Base class for annotation states
abstract class AnnotationState extends Equatable {
  const AnnotationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any annotations are loaded
class AnnotationInitial extends AnnotationState {}

/// State when annotations are being loaded
class AnnotationLoading extends AnnotationState {}

/// State when annotations have been successfully loaded
class AnnotationLoaded extends AnnotationState {
  final List<Annotation> annotations;
  final String? filePath;

  const AnnotationLoaded(this.annotations, {this.filePath});

  @override
  List<Object?> get props => [annotations, filePath];
}

/// State when an annotation operation is successful
class AnnotationOperationSuccess extends AnnotationState {
  final String message;
  final List<Annotation> annotations;

  const AnnotationOperationSuccess(this.message, this.annotations);

  @override
  List<Object?> get props => [message, annotations];
}

/// State when an error occurs
class AnnotationError extends AnnotationState {
  final String message;

  const AnnotationError(this.message);

  @override
  List<Object?> get props => [message];
}
