// lib/registration/step4.dart
import 'package:flutter/material.dart';

class step4 extends StatefulWidget {
  final String? selectedGender;
  final double? selectedHeight;
  final double? selectedWeight;
  final void Function(double) onWeightSelected;
  final void Function() onGoBack;

  const step4({
    super.key,
    required this.selectedGender,
    required this.selectedHeight,
    required this.selectedWeight,
    required this.onWeightSelected,
    required this.onGoBack,
  });

  @override
  State<step4> createState() => _Step4State();
}

class _Step4State extends State<step4> {
  late double _weightValue;
  late FixedExtentScrollController _wholePartController;
  late FixedExtentScrollController _decimalPartController;

  @override
  void initState() {
    super.initState();
    _weightValue = widget.selectedWeight ?? 70.0;

    int wholePart = _weightValue.truncate();
    int decimalPart = (_weightValue * 10).truncate() % 10;

    _wholePartController = FixedExtentScrollController(
      initialItem: wholePart - 30,
    );
    _decimalPartController = FixedExtentScrollController(
      initialItem: decimalPart,
    );
  }

  @override
  void dispose() {
    _wholePartController.dispose();
    _decimalPartController.dispose();
    super.dispose();
  }

  double getIdealWeight() {
    if (widget.selectedHeight == null || widget.selectedGender == null) return 0.0;
    final height = widget.selectedHeight!;
    double idealWeight;
    if (widget.selectedGender == 'male') {
      idealWeight = height - (100 + (height - 100) / 20);
    } else {
      idealWeight = height - (100 + (height - 100) / 10);
    }
    return idealWeight < 30.0 ? 30.0 : idealWeight;
  }

  Color getWeightColor() {
    final idealWeight = getIdealWeight();
    final currentWeight = _weightValue;
    if (currentWeight >= idealWeight - 5 && currentWeight <= idealWeight + 5) {
      return Colors.green;
    } else if (currentWeight < idealWeight - 5) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final descriptionFontSize = isSmallScreen ? 14.0 : 16.0;
    final wheelFontSize = isSmallScreen ? 20.0 : 24.0;
    final displayFontSize = isSmallScreen ? 24.0 : 32.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;
    final wheelItemExtent = isSmallScreen ? 40.0 : 50.0;
    final wheelHeight = isSmallScreen ? 160.0 : 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сколько вы весите?',
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
            'Укажите ваш вес в килограммах.',
            style: TextStyle(
              fontSize: descriptionFontSize,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 25 : 40),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _wholePartController,
                  itemExtent: wheelItemExtent,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (int index) {
                    int newWholePart = 30 + index;
                    double newDecimalPart = _weightValue % 1;
                    double newWeight = newWholePart + newDecimalPart;
                    setState(() {
                      _weightValue = newWeight;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      int value = 30 + index;
                      double tempWeight = value + (_weightValue % 1);
                      bool isSelected = (tempWeight - _weightValue).abs() < 0.001;
                      return Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: wheelFontSize,
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 171,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: wheelHeight,
                color: Colors.grey[700],
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _decimalPartController,
                  itemExtent: wheelItemExtent,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (int index) {
                    double newDecimalPart = index / 10.0;
                    double newWholePart = _weightValue.truncate().toDouble();
                    double newWeight = newWholePart + newDecimalPart;
                    setState(() {
                      _weightValue = newWeight;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      double decimalPart = index / 10.0;
                      double tempWeight = (_weightValue.truncate().toDouble()) + decimalPart;
                      bool isSelected = (tempWeight - _weightValue).abs() < 0.001;
                      return Center(
                        child: Text(
                          '.${index.toString()}',
                          style: TextStyle(
                            fontSize: wheelFontSize,
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 10, // 0 до 9
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: heightValue),
        Center(
          child: Container(
            padding: EdgeInsets.all(paddingValue),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ТЕКУЩИЙ ВЕС',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  _weightValue.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: displayFontSize,
                    fontWeight: FontWeight.bold,
                    color: getWeightColor(),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Идеальный вес: ${getIdealWeight().toStringAsFixed(1)} кг',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: heightValue),
        Center(
          child: ElevatedButton(
            onPressed: () {
              widget.onWeightSelected(_weightValue);
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