// lib/steps/step1.dart
import 'package:flutter/material.dart';

class step1 extends StatelessWidget {
  final String? selectedGender;
  final void Function(String) onGenderSelected;

  const step1({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final cardWidth = screenWidth * 0.4;
    final cardHeight = isSmallScreen ? 180.0 : 220.0;
    final imageWidth = cardWidth * 0.75;
    final imageHeight = cardHeight * 0.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Какого вы пола?',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Приветствуем вас, для более точного подбора рациона питания, укажите свой пол',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 30 : 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGenderCard(
              'assets/img/male_icon.png',
              'Мужской',
              'male',
              selectedGender,
              onGenderSelected,
              cardWidth,
              cardHeight,
              imageWidth,
              imageHeight,
              isSmallScreen,
            ),
            _buildGenderCard(
              'assets/img/female_icon.png',
              'Женский',
              'female',
              selectedGender,
              onGenderSelected,
              cardWidth,
              cardHeight,
              imageWidth,
              imageHeight,
              isSmallScreen,
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            const Divider(color: Colors.grey, thickness: 1),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey[400],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard(
      String imagePath,
      String label,
      String value,
      String? selectedGender,
      void Function(String) onGenderSelected,
      double cardWidth,
      double cardHeight,
      double imageWidth,
      double imageHeight,
      bool isSmallScreen,
      ) {
    final isSelected = selectedGender == value;
    return GestureDetector(
      onTap: () => onGenderSelected(value),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[700]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.red
                  : Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}