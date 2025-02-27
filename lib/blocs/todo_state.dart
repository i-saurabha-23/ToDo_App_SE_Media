import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Task> tasks;

  TodoLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TodoError extends TodoState {
  final String message;

  TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
