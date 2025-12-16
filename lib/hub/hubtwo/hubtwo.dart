// lib/hub/hubtwo/hubtwo.dart
import 'package:flutter/material.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';
import 'package:Elite_KA/hub/hubtwo/screens/workout_create_screen.dart';
import 'package:Elite_KA/hub/hubtwo/screens/workout_edit_screen.dart';
import 'package:Elite_KA/hub/hubtwo/services/workout_storage_service.dart';

class HubTwo extends StatefulWidget {
  const HubTwo({super.key});

  @override
  State<HubTwo> createState() => _HubTwoState();
}

class _HubTwoState extends State<HubTwo> {
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final workouts = await WorkoutStorageService.loadWorkouts();
      if (mounted) {
        setState(() {
          _workouts = workouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewWorkout() async {
    final createdWorkout = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutCreateScreen(
          onWorkoutCreated: (workout) {
          },
        ),
      ),
    );
    if (createdWorkout != null) {
      final updatedWorkouts = [..._workouts, createdWorkout];
      await WorkoutStorageService.saveWorkouts(updatedWorkouts);
      if (mounted) {
        setState(() {
          _workouts = updatedWorkouts;
        });
      }
    }
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final contentFontSize = isSmallScreen ? 13.0 : 14.0;
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final buttonPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 20, vertical: 10)
        : EdgeInsets.symmetric(horizontal: 24, vertical: 12);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Удалить тренировку?',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Вы уверены, что хотите удалить «${workout.name}»? Это действие нельзя отменить.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: contentFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Colors.grey,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(
              'Удалить',
              style: TextStyle(fontSize: buttonFontSize),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await WorkoutStorageService.deleteWorkout(workout.id);
      if (mounted) {
        setState(() {
          _workouts.removeWhere((w) => w.id == workout.id);
        });
      }
    }
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
    final iconSize = isSmallScreen ? 20.0 : 22.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isSmallScreen ? 13.0 : 14.0;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            strokeWidth: isSmallScreen ? 3 : 4,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'ПЕРСОНАЛИЗ',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16.0 : 18.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: iconSize),
            onPressed: _loadWorkouts,
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _workouts.isEmpty
          ? _buildEmptyState(
        isSmallScreen: isSmallScreen,
        padding: padding,
        buttonFontSize: buttonFontSize,
        buttonPadding: buttonPadding,
        borderRadius: borderRadius,
      )
          : _buildWorkoutList(
        isSmallScreen: isSmallScreen,
        padding: padding,
        titleFontSize: titleFontSize,
        subtitleFontSize: subtitleFontSize,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _createNewWorkout,
        elevation: 0,
        child: Icon(Icons.add, color: Colors.white, size: isSmallScreen ? 24 : 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState({
    required bool isSmallScreen,
    required double padding,
    required double buttonFontSize,
    required EdgeInsets buttonPadding,
    required double borderRadius,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: isSmallScreen ? 80 : 100,
                color: Colors.grey,
              ),
              SizedBox(height: isSmallScreen ? 20 : 30),
              Text(
                'Создайте свою первую\nличную тренировку',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                'Настройте собственный особый\nраспорядок',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 30),
              ElevatedButton(
                onPressed: _createNewWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: Text(
                  '+ НАЧАЛО',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutList({
    required bool isSmallScreen,
    required double padding,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView.builder(
          itemCount: _workouts.length,
          itemBuilder: (context, index) {
            final workout = _workouts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutEditScreen(workout: workout),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 6),
                          Text(
                            '${workout.exerciseCount} упражнений',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: subtitleFontSize,
                            ),
                          ),
                          Text(
                            workout.formattedDate,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: subtitleFontSize - 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: isSmallScreen ? 20 : 22,
                      ),
                      onPressed: () => _deleteWorkout(workout),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}