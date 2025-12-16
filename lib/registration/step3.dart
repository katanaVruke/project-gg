// lib/registration/step3.dart
import 'package:flutter/material.dart';

class step3 extends StatefulWidget {
  final double? selectedHeight;
  final void Function(double) onHeightSelected;
  final void Function() onGoBack;

  const step3({
    super.key,
    required this.selectedHeight,
    required this.onHeightSelected,
    required this.onGoBack,
  });

  @override
  State<step3> createState() => _Step3State();
}

class _Step3State extends State<step3> {
  late double _heightValue;
  late FixedExtentScrollController _wholePartController;
  late FixedExtentScrollController _decimalPartController;

  @override
  void initState() {
    super.initState();
    _heightValue = widget.selectedHeight ?? 175.0;

    int wholePart = _heightValue.truncate();
    int decimalPart = (_heightValue * 10).truncate() % 10;

    _wholePartController = FixedExtentScrollController(
      initialItem: wholePart - 100,
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final descriptionFontSize = isSmallScreen ? 14.0 : 16.0;
    final wheelFontSize = isSmallScreen ? 20.0 : 24.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;
    final wheelItemExtent = isSmallScreen ? 40.0 : 50.0;
    final wheelHeight = isSmallScreen ? 160.0 : 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Какой у вас рост?',
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
            'Укажите ваш рост в сантиметрах. Это поможет точно рассчитать вашу норму калорий и ИМТ.',
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
                    int newWholePart = 100 + index;
                    double newDecimalPart = _heightValue % 1;
                    double newHeight = newWholePart + newDecimalPart;
                    setState(() {
                      _heightValue = newHeight;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      int value = 100 + index;
                      double tempHeight = value + (_heightValue % 1);
                      bool isSelected = (tempHeight - _heightValue).abs() < 0.001;
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
                    childCount: 151,
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
                    double newWholePart = _heightValue.truncate().toDouble();
                    double newHeight = newWholePart + newDecimalPart;
                    setState(() {
                      _heightValue = newHeight;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      double decimalPart = index / 10.0;
                      double tempHeight = (_heightValue.truncate().toDouble()) + decimalPart;
                      bool isSelected = (tempHeight - _heightValue).abs() < 0.001;
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
          child: ElevatedButton(
            onPressed: () {
              widget.onHeightSelected(_heightValue);
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