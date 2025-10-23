// lib/Hub/HubMain.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Elite_KA/Hub/HubOne/HubOne.dart';
import 'HubTwo/HubTwo.dart';
import 'HubThree/HubThree.dart';
import 'HubFour/HubFour.dart';
import 'HubFive/HubFive.dart';

class HubMain extends StatefulWidget {
  const HubMain({super.key});

  @override
  State<HubMain> createState() => _HubMainState();
}

class _HubMainState extends State<HubMain> {
  int _selectedIndex = 0;

  String? selectedGender;
  int? selectedAge;
  double? selectedHeight;
  double? selectedWeight;
  String? selectedFatPercentage;
  List<String>? selectedEquipment;

  final List<Widget> _pages = [
    const HubOne(),
    const HubTwo(),
    const HubThree(),
    const HubFour(),
    const HubFive(),
  ];

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
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
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
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