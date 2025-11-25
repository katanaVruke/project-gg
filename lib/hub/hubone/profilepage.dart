// lib/hub/hubone/profilepage.dart
import 'package:Elite_KA/hub/hubOne/fat.dart';
import 'package:Elite_KA/hub/hubOne/target.dart';
import 'package:Elite_KA/hub/hubOne/tools.dart';
import 'package:Elite_KA/hub/hubone/activity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../supabase/supabase_service.dart';
import '../../supabase/supabase_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedGender;
  int? selectedAge;
  double? selectedWeight;
  double? selectedHeight;
  String? selectedFatPercentage;
  List<String>? selectedEquipment;
  String? selectedTarget;
  String? selectedActivityLevel;

  // Временные переменные для хранения изменений до подтверждения
  String? _tempGender;
  int? _tempAge;
  double? _tempWeight;
  double? _tempHeight;
  String? _tempFatPercentage;
  List<String>? _tempEquipment;
  String? _tempTarget;
  String? _tempActivityLevel;

  @override
  void initState() {
    super.initState();
    _loadUserDataFromPrefs();
  }

  Future<void> _loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString('selectedGender');
      selectedAge = prefs.getInt('selectedAge');
      selectedWeight = prefs.getDouble('selectedWeight');
      selectedHeight = prefs.getDouble('selectedHeight');
      selectedFatPercentage = prefs.getString('selectedFatPercentage');
      selectedEquipment = prefs.getStringList('selectedEquipment');
      selectedTarget = prefs.getString('selectedTarget');
      selectedActivityLevel = prefs.getString('selectedActivityLevel');

      // Инициализируем временные переменные
      _tempGender = selectedGender;
      _tempAge = selectedAge;
      _tempWeight = selectedWeight;
      _tempHeight = selectedHeight;
      _tempFatPercentage = selectedFatPercentage;
      _tempEquipment = selectedEquipment;
      _tempTarget = selectedTarget;
      _tempActivityLevel = selectedActivityLevel;
    });
  }

  String getEquipmentText(List<String>? equipment) {
    if (equipment == null || equipment.isEmpty) {
      return 'Выбрано 0';
    }
    if (equipment.contains('none')) {
      return 'Ничего';
    }
    if (equipment.contains('all')) {
      return 'Все оборудование';
    }
    int count = equipment.where((e) => e != 'all' && e != 'none').length;
    return 'Выбрано $count';
  }

  String getActivityDescription(String? level) {
    switch (level) {
      case 'minimal':
        return '';
      case 'low':
        return '(1-2 тренировки в неделю)';
      case 'moderate':
        return '(3 тренировки в неделю)';
      case 'high':
        return '(4-5 тренировки в неделю)';
      default:
        return '';
    }
  }

  String getActivityText(String? level) {
    switch (level) {
      case 'minimal':
        return 'Минимальная активность';
      case 'low':
        return 'Слабая активность';
      case 'moderate':
        return 'Средняя активность';
      case 'high':
        return 'Высокая активность';
      default:
        return 'Не указана';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final paddingValue = isSmallScreen ? 16.0 : 20.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;

    return WillPopScope(
      onWillPop: () async {
        // При возврате через системную кнопку не сохраняем изменения
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Мой Профиль',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.red,
                size: isSmallScreen ? 24 : 28,
              ),
              onPressed: () async {
                // Сохраняем все изменения в shared_preferences и supabase
                await _saveAllChanges();
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ToolsPage()),
                      );
                      if (result != null) {
                        setState(() {
                          _tempEquipment = result;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingValue,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Доступное оборудование',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                getEquipmentText(_tempEquipment),
                                style: TextStyle(
                                  fontSize: itemFontSize,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: heightValue),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TargetPage(currentTarget: _tempTarget),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _tempTarget = result as String;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingValue,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Цель',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                _tempTarget != null && _tempTarget!.isNotEmpty ? _tempTarget! : 'Не указана',
                                style: TextStyle(
                                  fontSize: itemFontSize,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: heightValue),
                  // Add the new Activity section
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityPage(currentActivityLevel: _tempActivityLevel),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _tempActivityLevel = result as String;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingValue,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Активность',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                getActivityText(_tempActivityLevel),
                                style: TextStyle(
                                  fontSize: itemFontSize,
                                  color: Colors.white,
                                ),
                              ),
                              if (_tempActivityLevel != null && getActivityDescription(_tempActivityLevel) != '')
                                Text(
                                  getActivityDescription(_tempActivityLevel),
                                  style: TextStyle(
                                    fontSize: itemFontSize * 0.9,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: heightValue * 1.5),
                  Text(
                    'Основные данные',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: heightValue),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Пол
                        GestureDetector(
                          onTap: () => _showGenderSelection(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: paddingValue,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Пол',
                                  style: TextStyle(
                                    fontSize: itemFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _tempGender == 'male'
                                          ? 'Мужской'
                                          : _tempGender == 'female'
                                          ? 'Женский'
                                          : 'Не указан',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[700], height: 1, thickness: 1),
                        GestureDetector(
                          onTap: () => _showAgeSelection(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: paddingValue,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Возраст',
                                  style: TextStyle(
                                    fontSize: itemFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _tempAge != null
                                          ? '${_tempAge!} ${_getAgeSuffix(_tempAge!)}'
                                          : 'Не указан',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[700], height: 1, thickness: 1),
                        GestureDetector(
                          onTap: () => _showWeightSelection(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: paddingValue,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Текущий вес',
                                  style: TextStyle(
                                    fontSize: itemFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _tempWeight != null
                                          ? '${_tempWeight!.toStringAsFixed(1)} кг'
                                          : 'Не указан',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[700], height: 1, thickness: 1),
                        GestureDetector(
                          onTap: () => _showHeightSelection(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: paddingValue,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Рост',
                                  style: TextStyle(
                                    fontSize: itemFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _tempHeight != null
                                          ? '${_tempHeight!.toStringAsFixed(1)} см'
                                          : 'Не указан',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey[700], height: 1, thickness: 1),
                        GestureDetector(
                          onTap: () => _showFatSelection(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: paddingValue,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Процент жира',
                                  style: TextStyle(
                                    fontSize: itemFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _tempFatPercentage ?? 'Не указан',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 6 : 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAgeSuffix(int age) {
    if (age >= 11 && age <= 14) {
      return 'лет';
    }
    final lastDigit = age % 10;
    if (lastDigit == 1) {
      return 'год';
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return 'года';
    } else {
      return 'лет';
    }
  }

  Future<void> _showGenderSelection() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    String? newGender = _tempGender;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Выберите пол',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(
                      'Мужской',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                      ),
                    ),
                    value: 'male',
                    groupValue: newGender,
                    onChanged: (value) {
                      setState(() {
                        newGender = value;
                      });
                    },
                    activeColor: Colors.red,
                    selected: newGender == 'male',
                    selectedTileColor: Colors.grey[700],
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'Женский',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                      ),
                    ),
                    value: 'female',
                    groupValue: newGender,
                    onChanged: (value) {
                      setState(() {
                        newGender = value;
                      });
                    },
                    activeColor: Colors.red,
                    selected: newGender == 'female',
                    selectedTileColor: Colors.grey[700],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (newGender != null) {
                      setState(() {
                        _tempGender = newGender;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAgeSelection() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    int currentAge = _tempAge ?? 30;
    int currentAgeValue = currentAge;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Выберите возраст',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          content: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  height: isSmallScreen ? 160 : 200,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: isSmallScreen ? 32.0 : 40.0,
                    diameterRatio: 1.2,
                    perspective: 0.002,
                    controller: FixedExtentScrollController(initialItem: currentAgeValue - 15),
                    onSelectedItemChanged: (index) {
                      int newAge = index + 15;
                      setState(() {
                        currentAgeValue = newAge;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        int age = index + 15;
                        bool isSelected = age == currentAgeValue;
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            '$age',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16.0 : 20.0,
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      childCount: 56,
                    ),
                  ),
                );
              }
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _tempAge = currentAgeValue;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showHeightSelection() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    double currentHeight = _tempHeight ?? 175.0;
    double currentHeightValue = currentHeight;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Выберите рост (см)',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          content: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: isSmallScreen ? 160 : 200,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: isSmallScreen ? 40.0 : 50.0,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(
                            initialItem: (currentHeightValue.truncate() - 100),
                          ),
                          onSelectedItemChanged: (index) {
                            int wholePart = index + 100;
                            double newHeight = wholePart + (currentHeightValue % 1);
                            setState(() {
                              currentHeightValue = newHeight;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              int value = index + 100;
                              double tempHeight = value + (currentHeightValue % 1);
                              bool isSelected = (tempHeight - currentHeightValue).abs() < 0.001;
                              return Center(
                                child: Text(
                                  '$value',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20.0 : 24.0,
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
                    ),
                    Expanded(
                      child: SizedBox(
                        height: isSmallScreen ? 160 : 200,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: isSmallScreen ? 40.0 : 50.0,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(
                            initialItem: ((currentHeightValue * 10) % 10).toInt(),
                          ),
                          onSelectedItemChanged: (index) {
                            double decimalPart = index / 10.0;
                            double newHeight = (currentHeightValue.truncate()) + decimalPart;
                            setState(() {
                              currentHeightValue = newHeight;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              double decimalPart = index / 10.0;
                              double tempHeight = (currentHeightValue.truncate()) + decimalPart;
                              bool isSelected = (tempHeight - currentHeightValue).abs() < 0.001;
                              return Center(
                                child: Text(
                                  '.${index.toString()}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20.0 : 24.0,
                                    color: isSelected ? Colors.white : Colors.grey[400],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _tempHeight = currentHeightValue;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWeightSelection() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    double currentWeight = _tempWeight ?? 70.0;
    double currentWeightValue = currentWeight;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Выберите вес (кг)',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          content: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: isSmallScreen ? 160 : 200,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: isSmallScreen ? 40.0 : 50.0,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(
                            initialItem: (currentWeightValue.truncate() - 40),
                          ),
                          onSelectedItemChanged: (index) {
                            int wholePart = index + 40;
                            double newWeight = wholePart + (currentWeightValue % 1);
                            setState(() {
                              currentWeightValue = newWeight;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              int value = index + 40;
                              double tempWeight = value + (currentWeightValue % 1);
                              bool isSelected = (tempWeight - currentWeightValue).abs() < 0.001;
                              return Center(
                                child: Text(
                                  '$value',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20.0 : 24.0,
                                    color: isSelected ? Colors.white : Colors.grey[400],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: 111,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: isSmallScreen ? 160 : 200,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: isSmallScreen ? 40.0 : 50.0,
                          diameterRatio: 1.2,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          controller: FixedExtentScrollController(
                            initialItem: ((currentWeightValue * 10) % 10).toInt(),
                          ),
                          onSelectedItemChanged: (index) {
                            double decimalPart = index / 10.0;
                            double newWeight = (currentWeightValue.truncate()) + decimalPart;
                            setState(() {
                              currentWeightValue = newWeight;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              double decimalPart = index / 10.0;
                              double tempWeight = (currentWeightValue.truncate()) + decimalPart;
                              bool isSelected = (tempWeight - currentWeightValue).abs() < 0.001;
                              return Center(
                                child: Text(
                                  '.${index.toString()}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20.0 : 24.0,
                                    color: isSelected ? Colors.white : Colors.grey[400],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _tempWeight = currentWeightValue;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFatSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FatPage(
          selectedGender: _tempGender,
          initialFatPercentage: _tempFatPercentage,
          onFatPercentageSelected: (newValue) async {
            setState(() {
              _tempFatPercentage = newValue;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _tempFatPercentage = result as String;
      });
    }
  }

  Future<void> _saveAllChanges() async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем все временные изменения в shared_preferences
    await prefs.setString('selectedGender', _tempGender ?? '');
    await prefs.setInt('selectedAge', _tempAge ?? 0);
    await prefs.setDouble('selectedWeight', _tempWeight ?? 0.0);
    await prefs.setDouble('selectedHeight', _tempHeight ?? 0.0);
    await prefs.setString('selectedFatPercentage', _tempFatPercentage ?? '');
    await prefs.setStringList('selectedEquipment', _tempEquipment ?? []);
    await prefs.setString('selectedTarget', _tempTarget ?? '');
    await prefs.setString('selectedActivityLevel', _tempActivityLevel ?? '');

    // Синхронизируем с Supabase
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      // Обновляем основной профиль
      await SupabaseService.updateUserProfile(
        user.id,
        selectedGender: _tempGender,
        selectedAge: _tempAge,
        selectedHeight: _tempHeight,
        selectedWeight: _tempWeight,
        selectedFatPercentage: _tempFatPercentage,
        selectedEquipment: _tempEquipment,
      );

      // Обновляем цели и активности
      await SupabaseService.updateUserGoalsAndActivities(
        user.id,
        selectedTarget: _tempTarget,
        selectedActivityLevel: _tempActivityLevel,
      );
    }

    // Обновляем основные переменные
    setState(() {
      selectedGender = _tempGender;
      selectedAge = _tempAge;
      selectedWeight = _tempWeight;
      selectedHeight = _tempHeight;
      selectedFatPercentage = _tempFatPercentage;
      selectedEquipment = _tempEquipment;
      selectedTarget = _tempTarget;
      selectedActivityLevel = _tempActivityLevel;
    });

    // Показываем сообщение об успешном сохранении
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Данные успешно сохранены'),
        backgroundColor: Colors.green,
      ),
    );
  }
}