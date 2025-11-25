// lib/hub/hubtwo/screens/workout_create_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';
import 'package:Elite_KA/hub/hubtwo/screens/exercise_picker_screen.dart';

class WorkoutCreateScreen extends StatefulWidget {
  const WorkoutCreateScreen({super.key, required Null Function(dynamic workout) onWorkoutCreated});

  @override
  State<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends State<WorkoutCreateScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Новая тренировка');
  final List<WorkoutExercise> _selectedExercises = [];

  void _openExercisePicker() async {
    final List<WorkoutExercise>? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePickerScreen(
          selectedExercises: _selectedExercises,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedExercises.clear();
        _selectedExercises.addAll(selected);
      });
    }
  }

  void _saveWorkout() {
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[900]!,
          content: Center(
            child: Text(
              'Добавьте хотя бы одно упражнение',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final newWorkout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim().isEmpty ? 'Новая тренировка' : _nameController.text,
      createdAt: DateTime.now(),
      exercises: _selectedExercises,
    );

    Navigator.of(context).pop(newWorkout);
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
    final verticalSpacing = isSmallScreen ? 12.0 : 20.0;
    final chipFontSize = isSmallScreen ? 13.0 : 14.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Создание тренировки',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white, size: isSmallScreen ? 20 : 24),
            onPressed: _saveWorkout,
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textFieldFontSize,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
                ),
              ),
              SizedBox(height: verticalSpacing),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxHeight = constraints.maxHeight > 180 ? constraints.maxHeight - 120 : 120.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Упражнения',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),

                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxHeight: maxHeight),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedExercises.map((ex) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                            child: Text(
                                              ex.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: chipFontSize,
                                                height: 1.3,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                              maxLines: null,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 6),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            icon: Icon(
                                              Icons.close,
                                              size: isSmallScreen ? 16 : 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _selectedExercises.remove(ex);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: verticalSpacing),

              Center(
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    onPressed: _openExercisePicker,
                    icon: Icon(Icons.add, size: isSmallScreen ? 18 : 20),
                    label: Text(
                      'Добавить упражнения',
                      style: TextStyle(fontSize: buttonFontSize),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: buttonPadding,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}