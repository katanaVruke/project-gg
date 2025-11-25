// lib/hub/hubtwo/screens/workout_execute_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';
import 'package:Elite_KA/hub/hubtwo/screens/workout_complete_screen.dart';

class WorkoutExecuteScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutExecuteScreen({super.key, required this.workout});

  @override
  State<WorkoutExecuteScreen> createState() => _WorkoutExecuteScreenState();
}

class _WorkoutExecuteScreenState extends State<WorkoutExecuteScreen> {
  final DateTime _startTime = DateTime.now();
  late Workout _workout;
  late Timer _timer;
  int _elapsedSeconds = 0;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds = _stopwatch.elapsed.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _updateSet(int exerciseIndex, int setIndex, {required int weight, required int reps}) {
    setState(() {
      final updatedSets = List<WorkoutSet>.from(_workout.exercises[exerciseIndex].sets);
      updatedSets[setIndex] = updatedSets[setIndex].copyWith(weight: weight, reps: reps);
      final updatedExercises = List<WorkoutExercise>.from(_workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercises[exerciseIndex].copyWith(sets: updatedSets);
      _workout = _workout.copyWith(exercises: updatedExercises);
    });
  }

  void _toggleSetCompleted(int exerciseIndex, int setIndex) {
    setState(() {
      final updatedSets = List<WorkoutSet>.from(_workout.exercises[exerciseIndex].sets);
      final currentSet = updatedSets[setIndex];
      updatedSets[setIndex] = currentSet.copyWith(isCompleted: !currentSet.isCompleted);
      final updatedExercises = List<WorkoutExercise>.from(_workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercises[exerciseIndex].copyWith(sets: updatedSets);
      _workout = _workout.copyWith(exercises: updatedExercises);
    });
  }

  void _finishWorkout() {
    _timer.cancel();
    _stopwatch.stop();
    final duration = Duration(seconds: _elapsedSeconds);
    final endTime = DateTime.now();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCompleteScreen(
          workout: _workout,
          duration: duration,
          startTime: _startTime,
          endTime: endTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 20, vertical: 12)
        : EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final textFieldFontSize = isSmallScreen ? 14.0 : 16.0;
    final containerPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _workout.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: isSmallScreen ? 20 : 24),
          onPressed: () {
            _timer.cancel();
            Navigator.pop(context);
          },
        ),
        actions: [
          Text(
            _formatDuration(_elapsedSeconds),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: ListView.builder(
            itemCount: _workout.exercises.length,
            itemBuilder: (context, exIndex) {
              final exercise = _workout.exercises[exIndex];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: containerPadding,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(exercise.imageUrl),
                          backgroundColor: Colors.grey[800],
                          radius: isSmallScreen ? 20 : 24,
                        ),
                        SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            exercise.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 16.0 : 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    ...exercise.sets.map((set) {
                      final setIndex = exercise.sets.indexOf(set);
                      return _buildSetRow(
                        set: set,
                        onWeightChanged: (val) =>
                            _updateSet(exIndex, setIndex, weight: val, reps: set.reps),
                        onRepsChanged: (val) =>
                            _updateSet(exIndex, setIndex, weight: set.weight, reps: val),
                        onToggleCompleted: () => _toggleSetCompleted(exIndex, setIndex),
                        isSmallScreen: isSmallScreen,
                        textFieldFontSize: textFieldFontSize,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: ElevatedButton(
            onPressed: _finishWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(
              'ЗАКОНЧИТЬ ТРЕНИРОВКУ',
              style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetRow({
    required WorkoutSet set,
    required Function(int) onWeightChanged,
    required Function(int) onRepsChanged,
    required VoidCallback onToggleCompleted,
    required bool isSmallScreen,
    required double textFieldFontSize,
  }) {
    return Container(
      margin: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 28 : 32,
                  alignment: Alignment.center,
                  child: Text(
                    'Сет ${set.number}',
                    style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 13 : 14),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                _buildNumberInput(
                  value: set.weight,
                  onChanged: onWeightChanged,
                  suffix: 'кг',
                  isSmallScreen: isSmallScreen,
                  fontSize: textFieldFontSize,
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                _buildNumberInput(
                  value: set.reps,
                  onChanged: onRepsChanged,
                  suffix: 'повт.',
                  isSmallScreen: isSmallScreen,
                  fontSize: textFieldFontSize,
                ),
              ],
            ),
          ),
          Checkbox(
            value: set.isCompleted,
            onChanged: (value) => onToggleCompleted(),
            activeColor: Colors.red,
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required int value,
    required Function(int) onChanged,
    required String suffix,
    required bool isSmallScreen,
    required double fontSize,
  }) {
    return Container(
      width: isSmallScreen ? 84 : 96,
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIconConstraints: BoxConstraints(),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
            child: Text(
              suffix,
              style: TextStyle(
                color: Colors.grey,
                fontSize: isSmallScreen ? 12 : 13,
              ),
            ),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
        ],
        onChanged: (text) {
          final num = int.tryParse(text) ?? 0;
          onChanged(num);
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '$hoursч $minutesм';
    } else {
      return '$minutesм $secsс';
    }
  }
}