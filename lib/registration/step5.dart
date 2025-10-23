// lib/registration/step5.dart
import 'package:flutter/material.dart';

class Step5 extends StatefulWidget {
  final String? selectedGender;
  final String? initialFatPercentage;
  final void Function(String) onFatPercentageSelected;
  final void Function() onGoBack;

  const Step5({
    super.key,
    required this.selectedGender,
    this.initialFatPercentage,
    required this.onFatPercentageSelected,
    required this.onGoBack,
  });

  @override
  State<Step5> createState() => _Step5State();
}

class _Step5State extends State<Step5> {
  String? _selectedFatPercentage;

  final List<Map<String, dynamic>> maleImages = [
    {'image': 'assets/img/fat/male_4_5.png', 'percentage': '4 - 5%'},
    {'image': 'assets/img/fat/male_6_7.png', 'percentage': '6 - 7%'},
    {'image': 'assets/img/fat/male_8_10.png', 'percentage': '8 - 10%'},
    {'image': 'assets/img/fat/male_11_12.png', 'percentage': '11 - 12%'},
    {'image': 'assets/img/fat/male_13_15.png', 'percentage': '13 - 15%'},
    {'image': 'assets/img/fat/male_16_19.png', 'percentage': '16 - 19%'},
    {'image': 'assets/img/fat/male_20_24.png', 'percentage': '20 - 24%'},
    {'image': 'assets/img/fat/male_25_30.png', 'percentage': '25 - 30%'},
    {'image': 'assets/img/fat/male_35_40.png', 'percentage': '35 - 40%'},
  ];

  final List<Map<String, dynamic>> femaleImages = [
    {'image': 'assets/img/fat/female_10_12.png', 'percentage': '10 - 12%'},
    {'image': 'assets/img/fat/female_15_17.png', 'percentage': '15 - 17%'},
    {'image': 'assets/img/fat/female_18_20.png', 'percentage': '18 - 20%'},
    {'image': 'assets/img/fat/female_21_23.png', 'percentage': '21 - 23%'},
    {'image': 'assets/img/fat/female_24_26.png', 'percentage': '24 - 26%'},
    {'image': 'assets/img/fat/female_27_29.png', 'percentage': '27 - 29%'},
    {'image': 'assets/img/fat/female_30_35.png', 'percentage': '30 - 35%'},
    {'image': 'assets/img/fat/female_36_40.png', 'percentage': '36 - 40%'},
    {'image': 'assets/img/fat/female_50+.png', 'percentage': '50%+'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFatPercentage = widget.initialFatPercentage;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final imageWidth = isSmallScreen ? 80.0 : 100.0;
    final imageHeight = isSmallScreen ? 80.0 : 100.0;
    final textFontSize = isSmallScreen ? 12.0 : 14.0;
    final spacingValue = isSmallScreen ? 8.0 : 10.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;
    final borderRadiusValue = isSmallScreen ? 12.0 : 16.0;

    int crossAxisCount = screenWidth > 600 ? 4 : 3;

    final images = widget.selectedGender == 'male' ? maleImages : femaleImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Какой у вас процент жира?',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Expanded(
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacingValue,
            mainAxisSpacing: spacingValue,
            childAspectRatio: 0.8,
            children: List.generate(images.length, (index) {
              final image = images[index]['image'];
              final percentage = images[index]['percentage'];
              final isSelected = _selectedFatPercentage == percentage;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFatPercentage = percentage;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey[800],
                    borderRadius: BorderRadius.circular(borderRadiusValue),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        image,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        percentage,
                        style: TextStyle(
                          fontSize: textFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: heightValue),
        Center(
          child: ElevatedButton(
            onPressed: _selectedFatPercentage != null
                ? () {
              widget.onFatPercentageSelected(_selectedFatPercentage!);
            }
                : null,
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
              disabledBackgroundColor: Colors.grey[800],
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
        SizedBox(height: isSmallScreen ? 12 : 16),
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