// lib/hub/hubtwo/screens/workout_details_screen.dart
import 'package:flutter/material.dart';
import 'package:Elite_KA/hub/hubtwo/models/completed_workout.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final CompletedWorkout workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;
    final padding = isSmall ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          workout.workoutName,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context),
                SizedBox(height: padding),
                ...workout.exercises.map((ex) => _buildExerciseCard(ex)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final duration = workout.duration;
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);
    final durationText = '$minutes:${secs.toString().padLeft(2, "0")}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Дата:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                workout.startTime
                    .toLocal()
                    .toString()
                    .substring(0, 16)
                    .replaceAll('T', ' '),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Время:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                durationText,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Объём:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                '${workout.totalVolume.toStringAsFixed(0)} кг',
                style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(CompletedExercise exercise) {
    final exerciseVolume = exercise.sets.fold<double>(0.0, (sum, set) => sum + (set.weight * set.reps));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${exercise.completedSets}/${exercise.totalSets}',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ..._buildSetRows(exercise.sets, exerciseVolume),
        ],
      ),
    );
  }

  List<Widget> _buildSetRows(List<CompletedSet> sets, double exerciseVolume) {
    final rows = <Widget>[];

    for (int i = 0; i < sets.length; i++) {
      final set = sets[i];
      final setVolume = set.weight * set.reps;

      rows.add(
        Row(
          children: [
            Container(
              width: 20,
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: set.reps > 0 ? Colors.grey : Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: set.reps > 0 ? 1.0 : 0.0,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  set.reps > 0 ? Colors.green : Colors.grey,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              set.reps > 0 ? '${set.weight}×${set.reps}' : '—',
              style: TextStyle(
                color: set.reps > 0 ? Colors.white : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              set.reps > 0 ? '${setVolume.toStringAsFixed(0)} кг' : '',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );

      if (i < sets.length - 1) rows.add(const SizedBox(height: 6));
    }

    rows.add(const Divider(height: 16, color: Colors.grey));
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Итого: ${exerciseVolume.toStringAsFixed(0)} кг',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return rows;
  }
}