// lib/hub/hubtwo/screens/exercise_picker_screen.dart
import 'package:Elite_KA/hub/hubthree/data/initial_exercises.dart' as initialData;
import 'package:Elite_KA/hub/hubthree/services/exercise_service.dart';
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:Elite_KA/hub/hubtwo/models/workout.dart';

class ExercisePickerScreen extends StatefulWidget {
  final List<WorkoutExercise> selectedExercises;
  const ExercisePickerScreen({super.key, required this.selectedExercises});

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  late List<Exercise> _allExercises;
  late List<Exercise> _filteredExercises;
  late Set<String> _selectedIds;
  Map<String, int> _setCounts = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_filterExercises);
  }

  Future<void> _loadExercises() async {
    final exercises = await ExerciseService.getAllExercises(initialData.getBaseExercises());
    final selectedIds = {
      for (var ex in widget.selectedExercises) ex.id,
    };
    final initialSetCounts = <String, int>{};
    for (var ex in widget.selectedExercises) {
      initialSetCounts[ex.id] = ex.setCount ?? 3;
    }
    if (mounted) {
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _selectedIds = selectedIds;
        _setCounts = initialSetCounts;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterExercises);
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = query.isEmpty
          ? _allExercises
          : _allExercises.where((ex) => ex.name.toLowerCase().contains(query)).toList();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
        if (!_setCounts.containsKey(id)) {
          _setCounts[id] = 3;
        }
      }
    });
  }

  void _changeSetCount(String id, int count) {
    setState(() {
      _setCounts[id] = count.clamp(1, 10);
    });
  }

  void _confirmSelection() {
    final selected = _allExercises
        .where((ex) => _selectedIds.contains(ex.id))
        .map((ex) => WorkoutExercise.fromExercise(
      ex,
      setCount: _setCounts[ex.id] ?? 3,
    ))
        .toList();
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Выберите упражнения', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Поиск упражнений...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.grey[900],
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: _allExercises.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : ListView.builder(
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final ex = _filteredExercises[index];
                return ExerciseItem(
                  exercise: ex,
                  isSelected: _selectedIds.contains(ex.id),
                  initialSetCount: _setCounts[ex.id] ?? 3,
                  onToggle: _toggleSelection,
                  onSetCountChanged: (count) => _changeSetCount(ex.id, count),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseItem extends StatefulWidget {
  final Exercise exercise;
  final bool isSelected;
  final int initialSetCount;
  final ValueChanged<String> onToggle;
  final ValueChanged<int> onSetCountChanged;

  const ExerciseItem({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.initialSetCount,
    required this.onToggle,
    required this.onSetCountChanged,
  });

  @override
  State<ExerciseItem> createState() => _ExerciseItemState();
}

class _ExerciseItemState extends State<ExerciseItem> with AutomaticKeepAliveClientMixin {
  late TextEditingController _setsController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: widget.initialSetCount.toString());
  }

  @override
  void didUpdateWidget(covariant ExerciseItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSetCount != widget.initialSetCount) {
      _setsController.text = widget.initialSetCount.toString();
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  widget.exercise.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.exercise.muscleGroups.join(', '),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  if (widget.isSelected)
                    Row(
                      children: [
                        const Text('Сетов: ', style: TextStyle(color: Colors.grey)),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _setsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            onChanged: (text) {
                              final num = int.tryParse(text) ?? 3;
                              widget.onSetCountChanged(num);
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Checkbox(
              value: widget.isSelected,
              onChanged: (value) => widget.onToggle(widget.exercise.id),
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}