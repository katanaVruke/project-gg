// lib/registration/step2.dart
import 'package:flutter/material.dart';

class step2 extends StatefulWidget {
  final int? selectedAge;
  final void Function(int) onAgeSelected;
  final void Function() onGoBack;

  const step2({
    super.key,
    required this.selectedAge,
    required this.onAgeSelected,
    required this.onGoBack,
  });

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  late int _ageSliderValue;

  @override
  void initState() {
    super.initState();
    _ageSliderValue = widget.selectedAge ?? 25;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final descriptionFontSize = isSmallScreen ? 14.0 : 16.0;
    final displayFontSize = isSmallScreen ? 20.0 : 24.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сколько вам лет?',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Container(
          padding: EdgeInsets.all(paddingValue),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Возраст поможет нам точнее рассчитать вашу дневную норму калорий и интенсивность тренировок.',
            style: TextStyle(
              fontSize: descriptionFontSize,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 25 : 40),
        Container(
          padding: EdgeInsets.symmetric(horizontal: paddingValue),
          child: Column(
            children: [
              Slider(
                value: _ageSliderValue.toDouble(),
                min: 15,
                max: 70,
                divisions: 55,
                activeColor: Colors.red,
                inactiveColor: Colors.grey[700],
                label: _ageSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _ageSliderValue = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '15',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  Text(
                    '70',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Container(
          padding: EdgeInsets.symmetric(horizontal: paddingValue),
          child: Container(
            padding: EdgeInsets.all(paddingValue),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _ageSliderValue.toString(),
                style: TextStyle(
                  fontSize: displayFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: heightValue),
        Center(
          child: ElevatedButton(
            onPressed: () {
              widget.onAgeSelected(_ageSliderValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 30 : 40,
                vertical: isSmallScreen ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Продолжить',
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Spacer(),
        Column(
          children: [
            const Divider(color: Colors.grey, thickness: 1),
            SizedBox(height: isSmallScreen ? 12 : 16),
            GestureDetector(
              onTap: widget.onGoBack,
              child: Text(
                'Назад',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[400],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}