// lib/hub/hubtwo/screens/workout_list_screen.dart
import 'package:flutter/material.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';
import 'package:Elite_KA/hub/hubtwo/screens/workout_create_screen.dart';
import 'package:Elite_KA/hub/hubtwo/screens/workout_edit_screen.dart';
import 'package:Elite_KA/hub/hubtwo/services/workout_storage_service.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  late Future<List<Workout>> _futureWorkouts;

  @override
  void initState() {
    super.initState();
    _reloadWorkouts();
  }

  void _reloadWorkouts() {
    _futureWorkouts = WorkoutStorageService.loadWorkouts();
  }

  Future<void> _createWorkout() async {
    final createdWorkout = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCreateScreen(
          onWorkoutCreated: (workout) {
            Navigator.pop(context, workout);
          },
        ),
      ),
    );
    if (createdWorkout != null) {
      final workouts = await WorkoutStorageService.loadWorkouts();
      workouts.add(createdWorkout);
      await WorkoutStorageService.saveWorkouts(workouts);
      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteWorkout(String id) async {
    await WorkoutStorageService.deleteWorkout(id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Мои тренировки', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reloadWorkouts,
          ),
        ],
      ),
      body: FutureBuilder<List<Workout>>(
        future: _futureWorkouts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Нет сохранённых тренировок',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final workouts = snapshot.data!;
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[900],
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: Text('${workout.exerciseCount}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(workout.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${workout.formattedDate} • ${workout.exerciseCount} упр.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutEditScreen(workout: workout),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkout(workout.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutEditScreen(workout: workout),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _createWorkout,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}