// lib/hub/hubMain.dart
import 'package:Elite_KA/hub/achievements.dart';
import 'package:Elite_KA/hub/hubfive/hubfive.dart';
import 'package:Elite_KA/hub/hubfour/hubfour.dart';
import 'package:Elite_KA/hub/hubone/hubone.dart';
import 'package:Elite_KA/hub/hubthree/hubthree.dart';
import 'package:Elite_KA/hub/hubtwo/hubtwo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class hubmain extends StatefulWidget {
  const hubmain({super.key});

  @override
  State<hubmain> createState() => _HubMainState();
}

class _HubMainState extends State<hubmain> {
  int _selectedIndex = 0;

  static const int _achievementsIndex = 5;

  String? selectedGender;
  int? selectedAge;
  double? selectedHeight;
  double? selectedWeight;
  String? selectedFatPercentage;
  List<String>? selectedEquipment;

  final List<Widget> _pages = [
    const hubone(),
    const hubtwo(),
    const hubthree(),
    const hubfour(),
    const hubfive(),
    const achievements(),
  ];

  final List<int> _secretCombination = [2, 1, 3, 4, 4, 0];
  List<int> _currentSequence = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedGender = prefs.getString('selectedGender');
      selectedAge = prefs.getInt('selectedAge');
      selectedHeight = prefs.getDouble('selectedHeight');
      selectedWeight = prefs.getDouble('selectedWeight');
      selectedFatPercentage = prefs.getString('selectedFatPercentage');
      selectedEquipment = prefs.getStringList('selectedEquipment');
    });
  }

  void _handleNavigationTap(int index) {
    if (_selectedIndex == _achievementsIndex) {
      setState(() {
        _selectedIndex = index;
      });
      return;
    }

    _currentSequence.add(index);

    if (_currentSequence.length > _secretCombination.length) {
      _currentSequence = _currentSequence
          .sublist(_currentSequence.length - _secretCombination.length);
    }

    if (_currentSequence.length == _secretCombination.length &&
        ListEquality().equals(_currentSequence, _secretCombination)) {
      _currentSequence.clear();
      setState(() {
        _selectedIndex = _achievementsIndex;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_selectedIndex == _achievementsIndex) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: _selectedIndex == _achievementsIndex
            ? null
            : Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(color: Colors.red),
            unselectedLabelStyle: const TextStyle(color: Colors.grey),
            currentIndex: _selectedIndex,
            onTap: _handleNavigationTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Я',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Тренировка',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_run),
                label: 'Упражнения',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Отчёт',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Питание',
              ),
            ],
          ),
        ),
      ),
    );
  }
}