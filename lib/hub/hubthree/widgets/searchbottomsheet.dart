//lib/hub/hubthree/widgets/searchbottomsheet.dart
import 'package:Elite_KA/Hub/HubThree/pages/ExerciseDetailPage.dart';
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:flutter/material.dart';

class SearchBottomSheet extends StatefulWidget {
  final List<Exercise> exercises;

  const SearchBottomSheet({super.key, required this.exercises});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  String _query = '';

  List<Exercise> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return widget.exercises.where((e) {
      final nameMatch = e.name.toLowerCase().contains(q);
      final muscleMatch = e.muscleGroups.any((m) => m.toLowerCase().contains(q));
      return nameMatch || muscleMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Поиск упражнений...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          Expanded(
            child: _query.isEmpty
                ? const Center(child: Text('Введите запрос', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final exercise = _results[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      exercise.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(exercise.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    exercise.muscleGroups.join(', '),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailPage(exercise: exercise),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}