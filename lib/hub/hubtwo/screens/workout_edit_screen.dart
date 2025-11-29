// lib/hub/hubtwo/screens/workout_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';
import 'package:Elite_KA/hub/hubtwo/screens/exercise_picker_screen.dart';
import 'package:Elite_KA/hub/hubtwo/screens/workout_execute_screen.dart';

class WorkoutEditScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutEditScreen({super.key, required this.workout});

  @override
  State<WorkoutEditScreen> createState() => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditScreen> {
  late Workout _workout;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
  }

  void _editWorkoutName() {
    final controller = TextEditingController(text: _workout.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Редактировать название', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _workout = _workout.copyWith(name: newName);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Сохранить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addExercises() async {
    final List<WorkoutExercise> currentExercises = _workout.exercises;
    final List<WorkoutExercise>? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePickerScreen(selectedExercises: currentExercises),
      ),
    );
    if (selected != null) {
      final existingIds = currentExercises.map((e) => e.id).toSet();
      final newExercises = selected.where((e) => !existingIds.contains(e.id)).toList();
      if (newExercises.isNotEmpty) {
        setState(() {
          _workout = _workout.copyWith(
            exercises: [..._workout.exercises, ...newExercises],
          );
        });
      }
    }
  }

  void _removeExercise(String id) {
    setState(() {
      _workout = _workout.copyWith(
        exercises: _workout.exercises.where((e) => e.id != id).toList(),
      );
    });
  }

  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutExecuteScreen(workout: _workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 16.0;

    return WillPopScope(
      onWillPop: () async {
        if (_workout != widget.workout) {
          Navigator.pop(context, _workout);
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(_workout.name, style: const TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editWorkoutName,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Упражнения',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    itemCount: _workout.exercises.length,
                    itemBuilder: (context, index) {
                      final ex = _workout.exercises[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    ex.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[800],
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.fitness_center,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _removeExercise(ex.id),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ex.description,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: ex.sets.map((set) {
                                return Chip(
                                  label: Text(
                                    '${set.weight} кг × ${set.reps}',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  backgroundColor: set.isFilled() ? Colors.red : Colors.grey[800],
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addExercises,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Добавить', style: TextStyle(fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _startWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text(
                            'НАЧАТЬ ТРЕНИРОВКУ',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}