// lib/hub/hubone/activity.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityPage extends StatefulWidget {
  final String? currentActivityLevel;
  const ActivityPage({super.key, this.currentActivityLevel});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? selectedActivityLevel;

  final Map<String, String> activityOptions = {
    'minimal': 'Минимальная активность',
    'low': 'Слабая активность',
    'moderate': 'Средняя активность',
    'high': 'Высокая активность',
  };

  final Map<String, String> activityDescriptions = {
    'minimal': '',
    'low': '(1-2 тренировки в неделю)',
    'moderate': '(3 тренировки в неделю)',
    'high': '(4-5 тренировки в неделю)',
  };

  @override
  void initState() {
    super.initState();
    selectedActivityLevel = widget.currentActivityLevel;
  }

  Future<void> _saveActivityLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedActivityLevel', selectedActivityLevel!);
    if (mounted) {
      Navigator.pop(context, selectedActivityLevel);
    }
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
          'Активность',
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
                'Выберите уровень активности',
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
                    ...activityOptions.entries.map((entry) {
                      final level = entry.key;
                      final label = entry.value;
                      final description = activityDescriptions[level] ?? '';
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedActivityLevel = level;
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
                              color: selectedActivityLevel == level ? Colors.red : Colors.grey[700]!,
                              width: selectedActivityLevel == level ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        color: Colors.white,
                                        fontWeight: selectedActivityLevel == level ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (selectedActivityLevel == level)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.red,
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                                ],
                              ),
                              if (description.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: isSmallScreen ? 2.0 : 4.0),
                                  child: Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: itemFontSize * 0.9,
                                      color: Colors.grey[400],
                                    ),
                                  ),
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
                    onPressed: selectedActivityLevel != null ? _saveActivityLevel : null,
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