//lib/hub/hubthree/pages/exercisedetailpage.dart
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:flutter/material.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final verticalSpacing = isSmallScreen ? 10.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'УПРАЖНЕНИЕ',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: exercise.image.isNotEmpty
                    ? Image.network(
                  exercise.image,
                  width: double.infinity,
                  height: isSmallScreen ? 200.0 : 250.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: isSmallScreen ? 200.0 : 250.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 56, color: Colors.grey),
                    );
                  },
                )
                    : Container(
                  width: double.infinity,
                  height: isSmallScreen ? 200.0 : 250.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, size: 56, color: Colors.grey),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                exercise.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: verticalSpacing * 0.75),
              _buildAttributeRow('Часть тела', exercise.bodyPart, isSmallScreen),
              _buildAttributeRow('Мышцы', exercise.muscleGroups.join(', '), isSmallScreen),
              _buildAttributeRow('Оборудование', exercise.equipment, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isSmallScreen ? 13.0 : 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14.0 : 16.0,
            ),
          ),
        ],
      ),
    );
  }
}