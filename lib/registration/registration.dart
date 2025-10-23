// lib/registration/registration.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Elite_KA/registration/Step1.dart';
import 'package:Elite_KA/registration/Step2.dart';
import 'package:Elite_KA/registration/Step3.dart';
import 'package:Elite_KA/registration/Step4.dart';
import 'package:Elite_KA/registration/Step5.dart';
import 'package:Elite_KA/registration/Step6.dart';

String? selectedGender;
int? selectedAge;
double? selectedHeight;
double? selectedWeight;
String? selectedFatPercentage;
List<String>? selectedEquipment;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 1;

  static const int totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 1) {
          setState(() {
            _currentStep -= 1;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text('Регистрация', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: LinearProgressIndicator(
              value: _currentStep / totalSteps,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 8,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return Step1(
          selectedGender: selectedGender,
          onGenderSelected: (value) {
            setState(() {
              selectedGender = value;
              _currentStep = 2;
            });
          },
        );
      case 2:
        return Step2(
          selectedAge: selectedAge,
          onAgeSelected: (value) {
            setState(() {
              selectedAge = value;
              _currentStep = 3;
            });
          },
          onGoBack: () {
            setState(() {
              _currentStep = 1;
            });
          },
        );
      case 3:
        return Step3(
          selectedHeight: selectedHeight,
          onHeightSelected: (value) {
            setState(() {
              selectedHeight = value;
              _currentStep = 4;
            });
          },
          onGoBack: () {
            setState(() {
              _currentStep = 2;
            });
          },
        );
      case 4:
        return Step4(
          selectedGender: selectedGender,
          selectedHeight: selectedHeight,
          selectedWeight: selectedWeight,
          onWeightSelected: (value) {
            setState(() {
              selectedWeight = value;
              _currentStep = 5;
            });
          },
          onGoBack: () {
            setState(() {
              _currentStep = 3;
            });
          },
        );
      case 5:
        return Step5(
          selectedGender: selectedGender,
          initialFatPercentage: selectedFatPercentage,
          onFatPercentageSelected: (value) {
            setState(() {
              selectedFatPercentage = value;
              _currentStep = 6;
            });
          },
          onGoBack: () {
            setState(() {
              _currentStep = 4;
            });
          },
        );
      case 6:
        return Step6(
          initialEquipment: selectedEquipment,
          onEquipmentSelected: (List<String> values) async {
            setState(() {
              selectedEquipment = values;
            });

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('selectedGender', selectedGender ?? '');
            await prefs.setInt('selectedAge', selectedAge ?? 0);
            await prefs.setDouble('selectedHeight', selectedHeight ?? 0.0);
            await prefs.setDouble('selectedWeight', selectedWeight ?? 0.0);
            await prefs.setString('selectedFatPercentage', selectedFatPercentage ?? '');
            await prefs.setStringList('selectedEquipment', selectedEquipment ?? []);

          },
          onGoBack: () {
            setState(() {
              _currentStep = 5;
            });
          },
        );
      default:
        return const Center(child: Text('Этап не реализован', style: TextStyle(color: Colors.white)));
    }
  }
}