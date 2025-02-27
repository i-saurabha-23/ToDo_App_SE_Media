import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to add a new task
class AddTaskEvent extends TodoEvent {
  final String title;

  AddTaskEvent(this.title);

  @override
  List<Object?> get props => [title];
}

// Event to mark a task as completed
class CompleteTaskEvent extends TodoEvent {
  final String taskId;

  CompleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Event to remove completed tasks after timer expires
class RemoveCompletedTasksEvent extends TodoEvent {}

// Event to remove a specific task by ID
class RemoveTaskEvent extends TodoEvent {
  final String taskId;

  RemoveTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Event to clear all data from storage
class ClearStorageEvent extends TodoEvent {}
