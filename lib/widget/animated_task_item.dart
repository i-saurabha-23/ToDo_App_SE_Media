import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todo_bloc.dart';
import '../blocs/todo_event.dart';
import '../models/task_model.dart';

class AnimatedTaskItem extends StatefulWidget {
  final Task task;

  const AnimatedTaskItem({Key? key, required this.task}) : super(key: key);

  @override
  _AnimatedTaskItemState createState() => _AnimatedTaskItemState();
}

class _AnimatedTaskItemState extends State<AnimatedTaskItem>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  int _remainingSeconds = 10;
  bool _showTimer = false;

  // Animation controller for task completion
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Create slide animation
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1, // Slide slightly to indicate completion
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Create opacity animation
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animations if task is already completed
    if (widget.task.isCompleted) {
      _animationController.value = 1.0; // Set to end state
      _showTimer = true;
      _calculateRemainingTime();
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(AnimatedTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start animations & countdown when task changes from incomplete to complete
    if (!oldWidget.task.isCompleted && widget.task.isCompleted) {
      _animationController.forward();
      setState(() {
        _showTimer = true;
      });
      _calculateRemainingTime();
      _startCountdown();
    }

    // Reverse animations if task changes from complete to incomplete
    if (oldWidget.task.isCompleted && !widget.task.isCompleted) {
      _animationController.reverse();
      setState(() {
        _showTimer = false;
      });
      _stopCountdown();
    }
  }

  void _calculateRemainingTime() {
    if (widget.task.completedAt != null) {
      final completedAt = widget.task.completedAt!;
      final deleteAt = completedAt.add(Duration(seconds: 10));
      final now = DateTime.now();

      if (deleteAt.isAfter(now)) {
        _remainingSeconds = deleteAt.difference(now).inSeconds;
      } else {
        _remainingSeconds = 0;
      }
    } else {
      _remainingSeconds = 10;
    }
  }

  void _startCountdown() {
    _stopCountdown(); // Cancel any existing timer

    // Create a new timer that fires every second
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _stopCountdown();

            // Start exit animation when timer reaches zero
            // This will be handled by the Dismissible widget's automatic removal
          }
        });
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    _animationController.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    if (_remainingSeconds > 7) return Colors.green;
    if (_remainingSeconds > 3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Add a subtle slide effect when the task is completed
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // When timer is at 0, trigger a slide out animation
        final isExiting = _showTimer && _remainingSeconds <= 0;

        return AnimatedSlide(
          offset: isExiting
              ? Offset(1.0, 0.0) // Slide out to the right when exiting
              : Offset(
                  _slideAnimation.value, 0.0), // Small slide for completion
          duration: isExiting
              ? Duration(milliseconds: 500) // Slower exit animation
              : Duration(milliseconds: 300),
          curve: isExiting ? Curves.easeInOut : Curves.easeOut,
          child: AnimatedOpacity(
            opacity: isExiting
                ? 0.0 // Fade out when exiting
                : _opacityAnimation.value,
            duration: isExiting
                ? Duration(milliseconds: 500)
                : Duration(milliseconds: 300),
            onEnd: () {
              // When the exit animation ends, remove the task if we're exiting
              if (isExiting && mounted) {
                context.read<TodoBloc>().add(RemoveTaskEvent(widget.task.id));
              }
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: widget.task.isCompleted,
                    onChanged: (bool? checked) {
                      if (checked != null && !widget.task.isCompleted) {
                        context
                            .read<TodoBloc>()
                            .add(CompleteTaskEvent(widget.task.id));
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    widget.task.title,
                    style: TextStyle(
                      decoration: widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: widget.task.isCompleted ? Colors.grey : null,
                      fontSize: 16,
                    ),
                  ),
                  // Countdown timer
                  trailing: _showTimer
                      ? Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getTimerColor().withOpacity(0.2),
                            border: Border.all(
                              color: _getTimerColor(),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$_remainingSeconds',
                              style: TextStyle(
                                color: _getTimerColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
