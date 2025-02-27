import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/widget/animated_task_item.dart';
import '../blocs/todo_bloc.dart';
import '../blocs/todo_event.dart';
import '../blocs/todo_state.dart';
import '../models/task_model.dart';

// Facebook color constants
class FacebookColors {
  static const Color primary = Color(0xFF1877F2); // Facebook blue
  static const Color background = Colors.white;
  static const Color cardBackground = Color(0xFFF0F2F5); // Facebook light gray
  static const Color textPrimary = Color(0xFF050505); // Facebook dark text
  static const Color textSecondary = Color(0xFF65676B); // Facebook gray text
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FacebookColors.background,
      appBar: AppBar(
        backgroundColor: FacebookColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "To-Do List",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
            tooltip: 'Clear all tasks',
            onPressed: () => _showClearConfirmation(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: FacebookColors.primary,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          hintText: "What do you need to do?",
                          hintStyle:
                              TextStyle(color: FacebookColors.textSecondary),
                          prefixIcon: Icon(Icons.edit_note_rounded,
                              color: FacebookColors.primary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: FacebookColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _addTask,
                        icon: Icon(Icons.add, color: Colors.white),
                        tooltip: 'Add Task',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Task List
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoInitial) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(FacebookColors.primary),
                    ),
                  );
                } else if (state is TodoLoaded) {
                  return _buildTaskList(state.tasks);
                } else if (state is TodoError) {
                  return Center(child: Text((state).message));
                } else {
                  return Center(child: Text("Something went wrong"));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FacebookColors.primary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Focus on the text field when FAB is pressed
          FocusScope.of(context).requestFocus(FocusNode());
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => _buildAddTaskBottomSheet(),
          );
        },
      ),
    );
  }

  Widget _buildAddTaskBottomSheet() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Task",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FacebookColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _taskController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter your task",
              hintStyle: TextStyle(color: FacebookColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: FacebookColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: FacebookColors.primary, width: 2),
              ),
            ),
            onSubmitted: (_) {
              _addTask();
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: FacebookColors.textSecondary),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FacebookColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _addTask();
                  Navigator.pop(context);
                },
                child: Text("Add Task"),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: FacebookColors.primary.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FacebookColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add a new task',
              style: TextStyle(color: FacebookColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Dismissible(
            key: Key(tasks[index].id),
            background: _buildDismissibleBackground(true),
            secondaryBackground: _buildDismissibleBackground(false),
            confirmDismiss: (direction) async {
              if (tasks[index].isCompleted) {
                return true;
              } else {
                context
                    .read<TodoBloc>()
                    .add(CompleteTaskEvent(tasks[index].id));
                return false;
              }
            },
            onDismissed: (direction) {
              context.read<TodoBloc>().add(RemoveTaskEvent(tasks[index].id));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task removed'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: FacebookColors.primary,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      context
                          .read<TodoBloc>()
                          .add(AddTaskEvent(tasks[index].title));
                    },
                  ),
                ),
              );
            },
            child: _buildTaskCard(tasks[index]),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      elevation: 0,
      color: FacebookColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted
                ? FacebookColors.primary
                : FacebookColors.textSecondary,
            size: 28,
          ),
          onPressed: () {
            context.read<TodoBloc>().add(CompleteTaskEvent(task.id));
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: FacebookColors.textPrimary,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: FacebookColors.textSecondary,
            decorationThickness: 2,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: FacebookColors.textSecondary,
          ),
          onPressed: () {
            context.read<TodoBloc>().add(RemoveTaskEvent(task.id));
          },
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground(bool isLeft) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      context.read<TodoBloc>().add(AddTaskEvent(_taskController.text));
      _taskController.clear();
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear All Tasks?',
            style: TextStyle(
              color: FacebookColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This will remove all your tasks. This action cannot be undone.',
            style: TextStyle(color: FacebookColors.textSecondary),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: FacebookColors.textSecondary),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Clear All'),
              onPressed: () {
                context.read<TodoBloc>().add(ClearStorageEvent());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All tasks cleared'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: FacebookColors.primary,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
