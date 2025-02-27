import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<Task> _tasks = [];
  Map<String, Timer> _deletionTimers = {}; // Track timers for each task

  TodoBloc() : super(TodoInitial()) {
    on<AddTaskEvent>(_onAddTask);
    on<CompleteTaskEvent>(_onCompleteTask);
    on<RemoveCompletedTasksEvent>(_onRemoveCompletedTasks);
    on<RemoveTaskEvent>(_onRemoveTask);
    on<ClearStorageEvent>(_onClearStorage);
    _loadTasks(); // Load tasks when Bloc is created
  }

  @override
  Future<void> close() {
    // Cancel all timers when the bloc is closed
    _deletionTimers.values.forEach((timer) => timer.cancel());
    _deletionTimers.clear();
    return super.close();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('tasks');
      if (tasksJson != null) {
        final List<dynamic> decodedList = jsonDecode(tasksJson);
        _tasks = decodedList.map((task) => Task.fromJson(task)).toList();

        // Check for any completed tasks that need timers restarted
        final now = DateTime.now();
        for (var task in _tasks) {
          if (task.isCompleted && task.completedAt != null) {
            final completedAt = task.completedAt!;
            final deleteAt = completedAt.add(Duration(seconds: 10));

            // If the deletion time is in the future, start a timer
            if (deleteAt.isAfter(now)) {
              final remainingSeconds = deleteAt.difference(now).inSeconds;
              _startDeletionTimer(task.id, remainingSeconds);
            } else {
              // If the deletion time has passed, remove the task
              _tasks.removeWhere((t) => t.id == task.id);
            }
          }
        }
      }
      emit(TodoLoaded(List.from(_tasks)));
    } catch (e) {
      emit(TodoError('Error loading tasks: $e'));
      _tasks = [];
      emit(TodoLoaded([]));
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tasksJson =
          jsonEncode(_tasks.map((task) => task.toJson()).toList());
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      emit(TodoError('Error saving tasks: $e'));
    }
  }

  // Add a new task
  void _onAddTask(AddTaskEvent event, Emitter<TodoState> emit) async {
    final newTask = Task(id: DateTime.now().toString(), title: event.title);
    _tasks.add(newTask);
    await _saveTasks();
    emit(TodoLoaded(List.from(_tasks)));
  }

  // Start a timer to delete a task after specified seconds
  void _startDeletionTimer(String taskId, int seconds) {
    // Cancel any existing timer for this task
    if (_deletionTimers.containsKey(taskId)) {
      _deletionTimers[taskId]?.cancel();
    }

    // Create a new timer
    _deletionTimers[taskId] = Timer(Duration(seconds: seconds), () {
      add(RemoveTaskEvent(taskId));
    });
  }

  // Mark task as completed and schedule removal
  void _onCompleteTask(CompleteTaskEvent event, Emitter<TodoState> emit) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == event.taskId);
    if (taskIndex != -1) {
      // Update task with completion status and timestamp
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      await _saveTasks();
      emit(TodoLoaded(List.from(_tasks)));

      // Schedule task removal after 10 seconds
      _startDeletionTimer(event.taskId, 10);
    }
  }

  // Remove a specific task by ID
  void _onRemoveTask(RemoveTaskEvent event, Emitter<TodoState> emit) async {
    // Remove the timer if it exists
    if (_deletionTimers.containsKey(event.taskId)) {
      _deletionTimers[event.taskId]?.cancel();
      _deletionTimers.remove(event.taskId);
    }

    // Remove the task from the list
    _tasks.removeWhere((task) => task.id == event.taskId);
    await _saveTasks();
    emit(TodoLoaded(List.from(_tasks)));
  }

  // Remove all completed tasks and update SharedPreferences
  void _onRemoveCompletedTasks(
      RemoveCompletedTasksEvent event, Emitter<TodoState> emit) async {
    // Get IDs of completed tasks before removing them
    final completedTaskIds = _tasks
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();

    // Cancel timers for completed tasks
    for (var id in completedTaskIds) {
      if (_deletionTimers.containsKey(id)) {
        _deletionTimers[id]?.cancel();
        _deletionTimers.remove(id);
      }
    }

    // Remove completed tasks
    _tasks.removeWhere((task) => task.isCompleted);
    await _saveTasks();
    emit(TodoLoaded(List.from(_tasks)));
  }

  // Clear all tasks and storage
  void _onClearStorage(ClearStorageEvent event, Emitter<TodoState> emit) async {
    // Clear all tasks
    _tasks.clear();

    // Cancel all pending deletion timers
    _deletionTimers.values.forEach((timer) => timer.cancel());
    _deletionTimers.clear();

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks');

    // Emit empty state
    emit(TodoLoaded([]));
  }
}
