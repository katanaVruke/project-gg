//lib/hub/hubthree/hubthree.dart
import 'package:Elite_KA/hub/Hubthree/pages/exercisedetailpage.dart';
import 'package:Elite_KA/hub/Hubthree/widgets/filterbottomsheet.dart';
import 'package:Elite_KA/hub/Hubthree/widgets/newexercisepage.dart';
import 'package:Elite_KA/hub/Hubthree/widgets/searchbottomsheet.dart';
import 'package:Elite_KA/hub/hubthree/services/exercise_service.dart';
import 'package:Elite_KA/hub/hubthree/data/initial_exercises.dart' as initialData;
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:flutter/material.dart';

class HubThree extends StatefulWidget {
  const HubThree({super.key});

  @override
  State<HubThree> createState() => _HubThreeState();
}

class _HubThreeState extends State<HubThree> {
  String _selectedBodyPart = 'Всё тело';
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });
    final exercises = await ExerciseService.getAllExercises(initialData.getBaseExercises());
    if (mounted) {
      setState(() {
        _allExercises = exercises;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    List<Exercise> filtered;
    if (_selectedBodyPart == 'Всё тело') {
      filtered = _allExercises;
    } else {
      filtered = _allExercises
          .where((e) => e.bodyPart == _selectedBodyPart)
          .toList();
    }

    filtered.sort((a, b) {
      if (a.isCustom && !b.isCustom) return -1;
      if (!a.isCustom && b.isCustom) return 1;
      return 0;
    });

    setState(() {
      _filteredExercises = filtered;
    });
  }

  void _onFilterChanged(String bodyPart) {
    setState(() {
      _selectedBodyPart = bodyPart;
      _applyFilter();
    });
  }

  String _getFilterText() {
    if (_selectedBodyPart == 'Всё тело') {
      return 'Все (${_allExercises.length})';
    } else {
      final count = _allExercises.where((e) => e.bodyPart == _selectedBodyPart).length;
      return '$_selectedBodyPart ($count)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final borderRadius = isSmallScreen ? 16.0 : 20.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final fabSize = isSmallScreen ? 56.0 : 64.0;
    final buttonPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'УПРАЖНЕНИЯ',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: iconSize),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SearchBottomSheet(exercises: _allExercises),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => FilterBottomSheet(
                            initialBodyPart: _selectedBodyPart,
                            onFilterChanged: _onFilterChanged,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        padding: buttonPadding,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list, size: iconSize, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            _getFilterText(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredExercises.isEmpty
                  ? Center(
                child: Text(
                  'Нет упражнений',
                  style: TextStyle(color: Colors.grey, fontSize: fontSize),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  return Dismissible(
                    key: Key(exercise.id),
                    direction: exercise.isCustom ? DismissDirection.endToStart : DismissDirection.none,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: padding),
                      child: Icon(Icons.delete, color: Colors.white, size: iconSize),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            final dialogPadding = isSmallScreen ? 12.0 : 16.0;
                            final btnFontSize = isSmallScreen ? 14.0 : 16.0;
                            return AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: Text(
                                'Удалить упражнение?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 18,
                                ),
                              ),
                              content: Text(
                                'Вы действительно хотите удалить «${exercise.name}»?',
                                style: TextStyle(color: Colors.grey),
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: dialogPadding, vertical: dialogPadding / 2),
                              actionsPadding: EdgeInsets.all(dialogPadding / 2),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                    'ОТМЕНА',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: btnFontSize,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: dialogPadding,
                                      vertical: dialogPadding / 2,
                                    ),
                                  ),
                                  child: Text(
                                    'УДАЛИТЬ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: btnFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed == true) {
                          await ExerciseService.removeCustomExercise(exercise.id, exercise.image);
                          await _loadExercises();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.grey[900],
                                content: Center(
                                  child: Text(
                                    'Упражнение удалено',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                        return confirmed ?? false;
                      }
                      return false;
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      leading: SizedBox(
                        width: isSmallScreen ? 56 : 64,
                        height: isSmallScreen ? 56 : 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: exercise.image.isNotEmpty
                                  ? Image.network(
                                exercise.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.fitness_center,
                                      size: isSmallScreen ? 28 : 32,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                                  : Container(
                                color: Colors.grey[800],
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.fitness_center,
                                  size: isSmallScreen ? 28 : 32,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            if (exercise.isCustom)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: fontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        exercise.muscleGroups.join(', '),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: subtitleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailPage(exercise: exercise),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () async {
            final newExercise = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewExercisePage()),
            );
            if (newExercise is Exercise) {
              await _loadExercises();
            }
          },
          child: Icon(Icons.add, color: Colors.white, size: isSmallScreen ? 28 : 32),
        ),
      ),
    );
  }
}