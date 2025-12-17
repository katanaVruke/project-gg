// lib/hub/hubFive/hubFive.dart
import 'dart:convert';
import 'package:Elite_KA/Hub/HubFive/food.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HubFive extends StatefulWidget {
  const HubFive({super.key});

  @override
  State<HubFive> createState() => _HubFiveState();
}

class _HubFiveState extends State<HubFive> {
  String? selectedGender;
  int? selectedAge;
  double? selectedWeight;
  double? selectedHeight;
  String? selectedFatPercentage;
  String? selectedTarget;
  String? selectedActivityLevel;

  double kcal = 0.0;
  double protein = 0.0;
  double fat = 0.0;
  double carbs = 0.0;

  double eatenKcal = 0.0;
  double eatenProtein = 0.0;
  double eatenFat = 0.0;
  double eatenCarbs = 0.0;
  String feedbackMessage = '';

  List<Color> feedbackColors = [];

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _loadEatenFoodsForToday();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString('selectedGender');
      selectedAge = prefs.getInt('selectedAge');
      selectedWeight = prefs.getDouble('selectedWeight');
      selectedHeight = prefs.getDouble('selectedHeight');
      selectedFatPercentage = prefs.getString('selectedFatPercentage');
      selectedTarget = prefs.getString('selectedTarget');
      selectedActivityLevel = prefs.getString('selectedActivityLevel');
    });

    if (selectedGender != null &&
        selectedAge != null &&
        selectedWeight != null &&
        selectedHeight != null &&
        selectedFatPercentage != null &&
        selectedTarget != null &&
        selectedActivityLevel != null) {
      calculateKbju();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadEatenFoodsForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'eaten_foods_${_formatDate(DateTime.now())}';
    final jsonString = prefs.getString(todayKey) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);

    double totalKcal = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;
    for (var item in list) {
      final dish = EatenDish.fromJson(item as Map<String, dynamic>);
      totalKcal += dish.totalKcal;
      totalProtein += dish.totalProtein;
      totalFat += dish.totalFat;
      totalCarbs += dish.totalCarbs;
    }

    setState(() {
      eatenKcal = totalKcal;
      eatenProtein = totalProtein;
      eatenFat = totalFat;
      eatenCarbs = totalCarbs;

      if (kcal > 0 && protein > 0 && fat > 0 && carbs > 0) {
        final kcalPercent = eatenKcal / kcal * 100;
        final proteinPercent = eatenProtein / protein * 100;
        final fatPercent = eatenFat / fat * 100;
        final carbsPercent = eatenCarbs / carbs * 100;

        String kcalFeedback = '';
        Color kcalColor = Colors.grey;

        String proteinFeedback = '';
        Color proteinColor = Colors.grey;

        String fatFeedback = '';
        Color fatColor = Colors.grey;

        String carbsFeedback = '';
        Color carbsColor = Colors.grey;

        if (kcalPercent > 110) {
          kcalFeedback = 'Превышение калорий!';
          kcalColor = Colors.red;
        } else if (kcalPercent < 90) {
          kcalFeedback = 'Не добрали до нормы калорий.';
          kcalColor = Colors.blue;
        } else {
          kcalFeedback = 'Норма калорий соблюдена.';
          kcalColor = Colors.green;
        }

        if (proteinPercent < 90) {
          proteinFeedback = 'Не добрали до нормы белков.';
          proteinColor = Colors.blue;
        } else {
          proteinFeedback = 'Норма белков соблюдена.';
          proteinColor = Colors.green;
        }

        if (fatPercent > 110) {
          fatFeedback = 'Превышение жиров!';
          fatColor = Colors.red;
        } else if (fatPercent < 90) {
          fatFeedback = 'Не добрали до нормы жиров.';
          fatColor = Colors.blue;
        } else {
          fatFeedback = 'Норма жиров соблюдена.';
          fatColor = Colors.green;
        }

        if (carbsPercent > 110) {
          carbsFeedback = 'Превышение углеводов!';
          carbsColor = Colors.red;
        } else if (carbsPercent < 90) {
          carbsFeedback = 'Не добрали до нормы углеводов.';
          carbsColor = Colors.blue;
        } else {
          carbsFeedback = 'Норма углеводов соблюдена.';
          carbsColor = Colors.green;
        }

        feedbackMessage = '$kcalFeedback\n$proteinFeedback\n$fatFeedback\n$carbsFeedback';
        feedbackColors = [kcalColor, proteinColor, fatColor, carbsColor];
      } else {
        feedbackMessage = '';
        feedbackColors = [];
      }
    });
  }

  double getActivityMultiplier(String? activityLevel) {
    switch (activityLevel) {
      case 'minimal':
        return 1.2;
      case 'low':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'high':
        return 1.725;
      default:
        return 1.2;
    }
  }

  double getAverageFatPercentage(String? fatPercentage) {
    if (fatPercentage == null) return 0.0;

    if (fatPercentage.contains('+')) {
      return 50.0;
    }

    final clean = fatPercentage.replaceAll('%', '').trim();
    final parts = clean.split(' - ');

    if (parts.length == 2) {
      final low = double.tryParse(parts[0]) ?? 0.0;
      final high = double.tryParse(parts[1]) ?? low;
      return (low + high) / 2;
    } else if (parts.length == 1) {
      return double.tryParse(parts[0]) ?? 0.0;
    }

    return 0.0;
  }

  void calculateKbju() {
    if (selectedGender == null ||
        selectedAge == null ||
        selectedWeight == null ||
        selectedHeight == null ||
        selectedFatPercentage == null ||
        selectedTarget == null ||
        selectedActivityLevel == null) {
      return;
    }

    double weight = selectedWeight!;
    double height = selectedHeight!;
    int age = selectedAge!;
    double fatPercentage = getAverageFatPercentage(selectedFatPercentage);
    double a = getActivityMultiplier(selectedActivityLevel);

    double baseKcal;
    if (selectedGender == 'male') {
      baseKcal = (10 * weight + 6.25 * height - 5 * age + 5) * a;
    } else {
      baseKcal = (10 * weight + 6.25 * height - 5 * age - 161) * a;
    }

    double adjustedKcal = baseKcal;
    if (selectedTarget == 'Похудение') {
      adjustedKcal *= 0.9;
    } else if (selectedTarget == 'Набор мышечной массы') {
      adjustedKcal *= 1.15;
    }

    double leanMass = weight - (weight * fatPercentage / 100);
    double proteinGrams = 2.0 * leanMass;
    double fatGrams = weight;
    double carbsGrams = 4.0 * weight;

    if (selectedTarget == 'Сушка') {
      proteinGrams = 2.5 * leanMass;
      carbsGrams /= 2.0;
    }

    setState(() {
      kcal = adjustedKcal;
      protein = proteinGrams;
      fat = fatGrams;
      carbs = carbsGrams;
    });
  }

  Widget _buildNutrientColumn(String label, String value, double fontSize) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void refreshEatenToday() {
    _loadEatenFoodsForToday();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final subtitleFontSize = isSmallScreen ? 16.0 : 18.0;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final paddingValue = isSmallScreen ? 16.0 : 20.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

    bool hasMissingData = selectedTarget == null || selectedTarget!.isEmpty ||
        selectedActivityLevel == null || selectedActivityLevel!.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Меню питания',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18.0 : 20.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingValue,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Норма КБЖУ',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      if (hasMissingData) ...[
                        Center(
                          child: Text(
                            'Вы не заполнили данные в профиле',
                            style: TextStyle(
                              fontSize: itemFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNutrientColumn('Б:', protein.toStringAsFixed(0), itemFontSize),
                            _buildNutrientColumn('Ж:', fat.toStringAsFixed(0), itemFontSize),
                            _buildNutrientColumn('У:', carbs.toStringAsFixed(0), itemFontSize),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                          child: Center(
                            child: Text(
                              'Ккал: ${kcal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: itemFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingValue,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Съедено сегодня',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNutrientColumn('Б:', eatenProtein.toStringAsFixed(1), itemFontSize),
                          _buildNutrientColumn('Ж:', eatenFat.toStringAsFixed(1), itemFontSize),
                          _buildNutrientColumn('У:', eatenCarbs.toStringAsFixed(1), itemFontSize),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                        child: Center(
                          child: Text(
                            'Ккал: ${eatenKcal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: itemFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (feedbackMessage.isNotEmpty && !hasMissingData) ...[
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Column(
                          children: [
                            ...List.generate(
                              feedbackMessage.split('\n').length,
                                  (index) => Center(
                                child: Text(
                                  feedbackMessage.split('\n')[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: feedbackColors[index],
                                    fontSize: itemFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodPage()),
                    );
                    refreshEatenToday();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 32 : 48,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Дневник питания',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],
          ),
        ),
      ),
    );
  }
}