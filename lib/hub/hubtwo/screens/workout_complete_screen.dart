// lib/hub/hubtwo/screens/workout_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';
import 'package:Elite_KA/hub/hubtwo/models/completed_workout.dart';
import 'package:Elite_KA/hub/hubtwo/services/completed_workout_storage_service.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final Workout workout;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;

  const WorkoutCompleteScreen({
    super.key,
    required this.workout,
    required this.duration,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  @override
  void initState() {
    super.initState();
    _saveCompletedWorkout();
  }

  Future<void> _saveCompletedWorkout() async {
    final completedExercises = widget.workout.exercises.map((ex) {
      final sets = ex.sets.map((s) => CompletedSet(reps: s.reps, weight: s.weight.toDouble())).toList();
      return CompletedExercise(exerciseName: ex.name, sets: sets);
    }).toList();

    final completed = CompletedWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutName: widget.workout.name,
      startTime: widget.startTime,
      endTime: widget.endTime,
      totalVolume: widget.workout.totalVolume.toDouble(),
      exercises: completedExercises,
    );

    await CompletedWorkoutStorageService.saveCompletedWorkout(completed);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final padding = isSmallScreen ? 12.0 : 24.0;
    final statCardPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final exerciseCardPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 20, vertical: 12)
        : EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 24.0 : 32.0;
    final subtitleFontSize = isSmallScreen ? 16.0 : 18.0;
    final statTitleFontSize = isSmallScreen ? 13.0 : 14.0;
    final statValueFontSize = isSmallScreen ? 18.0 : 20.0;
    final exerciseNameFontSize = isSmallScreen ? 14.0 : 16.0;
    final exerciseDetailFontSize = isSmallScreen ? 12.0 : 14.0;
    final verticalSpacing = isSmallScreen ? 16.0 : 30.0;
    final smallSpacing = isSmallScreen ? 8.0 : 16.0;

    final totalVolume = widget.workout.totalVolume;
    final formattedDuration = _formatDuration(widget.duration);
    final formattedStartTime = _formatDateTime(widget.startTime);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ТРЕНИРОВКА\nЗАВЕРШЕНА',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: verticalSpacing),

              _buildStatCard(
                title: 'Объем',
                value: '$totalVolume кг',
                icon: Icons.bar_chart,
                padding: statCardPadding,
                titleFontSize: statTitleFontSize,
                valueFontSize: statValueFontSize,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: smallSpacing),
              _buildStatCard(
                title: 'Длительность',
                value: formattedDuration,
                icon: Icons.timer,
                padding: statCardPadding,
                titleFontSize: statTitleFontSize,
                valueFontSize: statValueFontSize,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: smallSpacing),
              _buildStatCard(
                title: 'Начало',
                value: formattedStartTime,
                icon: Icons.calendar_today,
                padding: statCardPadding,
                titleFontSize: statTitleFontSize,
                valueFontSize: statValueFontSize,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: verticalSpacing),

              Text(
                'Выполненные упражнения',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: smallSpacing),

              Expanded(
                child: ListView.builder(
                  itemCount: widget.workout.exercises.length,
                  itemBuilder: (context, index) {
                    final ex = widget.workout.exercises[index];
                    final completedSets = ex.completedSets;
                    final totalSets = ex.totalSets;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: exerciseCardPadding,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                            child: Image.network(
                              ex.imageUrl,
                              width: isSmallScreen ? 40 : 48,
                              height: isSmallScreen ? 40 : 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: isSmallScreen ? 40 : 48,
                                  height: isSmallScreen ? 40 : 48,
                                  color: Colors.grey[800],
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: Colors.grey,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: exerciseNameFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  maxLines: 2,
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                Text(
                                  '$completedSets из $totalSets сетов выполнено',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: exerciseDetailFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            completedSets == totalSets ? Icons.check_circle : Icons.circle_outlined,
                            color: completedSets == totalSets ? Colors.green : Colors.grey,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: verticalSpacing),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: Text(
                  'НА ГЛАВНУЮ',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required EdgeInsets padding,
    required double titleFontSize,
    required double valueFontSize,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: titleFontSize,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hoursч $minutesм';
    } else {
      return '$minutesм $secondsс';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year в $hours:$minutes';
  }
}