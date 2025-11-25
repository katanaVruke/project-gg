// lib/hub/hubone/target.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TargetPage extends StatefulWidget {
  final String? currentTarget;

  const TargetPage({super.key, this.currentTarget});

  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
  String? selectedTarget;

  final Map<String, IconData> targetIcons = {
    'Набор мышечной массы': Icons.fitness_center,
    'Сушка': Icons.scale,
    'Похудение': Icons.scale,
    'Поддержание веса': Icons.favorite,
  };

  @override
  void initState() {
    super.initState();
    selectedTarget = widget.currentTarget;
  }

  Future<void> _saveTarget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTarget', selectedTarget!);
    Navigator.pop(context, selectedTarget);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final paddingValue = isSmallScreen ? 16.0 : 20.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Цель',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18.0 : 20.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выберите свою цель',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: heightValue),

              Expanded(
                child: ListView(
                  children: [
                    ...targetIcons.entries.map((entry) {
                      final target = entry.key;
                      final icon = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTarget = target;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingValue,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedTarget == target ? Colors.red : Colors.grey[700]!,
                              width: selectedTarget == target ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    icon,
                                    color: Colors.white,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                  SizedBox(width: isSmallScreen ? 10 : 12),
                                  Text(
                                    target,
                                    style: TextStyle(
                                      fontSize: itemFontSize,
                                      color: Colors.white,
                                      fontWeight: selectedTarget == target ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedTarget == target)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.red,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: isSmallScreen ? 16.0 : 20.0),
                  child: ElevatedButton(
                    onPressed: selectedTarget != null ? _saveTarget : null,
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
                      'Сохранить',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold,
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