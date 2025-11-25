// lib/registration/step6.dart
import 'package:Elite_KA/splash_screen.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Step6 extends StatefulWidget {
  final void Function(List<String>) onEquipmentSelected;
  final void Function() onGoBack;
  final List<String>? initialEquipment;

  const Step6({
    super.key,
    required this.onEquipmentSelected,
    required this.onGoBack,
    this.initialEquipment,
  });

  @override
  State<Step6> createState() => _Step6State();
}

class _Step6State extends State<Step6> {
  final Set<String> _selectedCategories = <String>{};
  bool _isNoneSelected = false;

  final List<Map<String, String>> categoryOptions = [
    {'label': 'Все оборудование', 'value': 'all'},
    {'label': 'Свободные веса', 'value': 'free_weights'},
    {'label': 'Стойки и скамьи', 'value': 'benches_stands'},
    {'label': 'Силовые тренажёры', 'value': 'machines'},
    {'label': 'Прочее оборудование', 'value': 'other'},
    {'label': 'Ничего', 'value': 'none'},
  ];

  final Map<String, List<String>> categoryToEquipment = {
    'free_weights': [
      'Гантели',
      'Гиря',
      'Диск штанги',
      'Штанга',
    ],
    'benches_stands': [
      'Горизонтальная скамья',
      'Наклонная скамья',
      'Скамья скотта',
      'Скамья для гиперэкстензии',
      'Перекладина для подтягиваний',
      'Перекладина для подтягиваний с подпоркой',
      'Стойка для махов',
      'Стойка для махов с подпоркой',
    ],
    'machines': [
      'Тренажёр для жима ногами',
      'Тренажёр для икроножных мышц',
      'Сидячий тренажёр для бедренных мышц',
      'Тренажёр для приседаний с упором',
      'Тренажёр для сгибания ног',
      'Тренажёр для экстензии ног',
      'Блочный тренажёр',
      'Тренажёр смита',
      'Тренажёр для скручивания',
      'Тренажёр для дельтовидных мышц',
      'Тренажёр для изолированного сгибания рук',
      'Тренажёр для разведения рук',
      'Тренажёр для экстензии трицепсов',
      'Наклонный тренажёр для грудных мышц',
      'Тренажёр для грудных мышц',
      'Тренажёр для сведения рук',
      'Тренажёр для тяги вертикального блока',
      'Тренажёр для тяги горизонтального блока',
    ],
    'other': [
      'Лента с ручками',
      'Ролик для пресса',
      'Степ',
      'Фитбол',
      'Медбол',
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialEquipment != null) {
      if (widget.initialEquipment!.contains('none')) {
        _isNoneSelected = true;
      } else {
        for (var category in categoryOptions) {
          if (category['value'] != 'none') {
            final equipmentInCategory = categoryToEquipment[category['value']] ?? [];
            if (equipmentInCategory.any((e) => widget.initialEquipment!.contains(e))) {
              _selectedCategories.add(category['value']!);
            }
          }
        }
      }
    }
  }

  void _navigateToSplashScreen() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  void _onOptionSelected(String value) {
    setState(() {
      if (value == 'none') {
        _selectedCategories.clear();
        _isNoneSelected = true;
      } else {
        if (_isNoneSelected) {
          _isNoneSelected = false;
        }

        if (value == 'all') {
          _selectedCategories.clear();
          for (var option in categoryOptions) {
            if (option['value'] != 'none') {
              _selectedCategories.add(option['value']!);
            }
          }
        } else {
          if (_selectedCategories.contains(value)) {
            _selectedCategories.remove(value);
            if (value != 'all' && _selectedCategories.contains('all')) {
              _selectedCategories.remove('all');
            }
          } else {
            _selectedCategories.add(value);
            bool allSelected = true;
            for (var option in categoryOptions) {
              if (option['value'] != 'all' && option['value'] != 'none') {
                if (!_selectedCategories.contains(option['value'])) {
                  allSelected = false;
                  break;
                }
              }
            }
            if (allSelected) {
              _selectedCategories.add('all');
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 24.0 : 28.0;
    final itemFontSize = isSmallScreen ? 16.0 : 18.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final heightValue = isSmallScreen ? 24.0 : 30.0;
    final borderRadiusValue = isSmallScreen ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Какое оборудование у вас есть?',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Expanded(
          child: ListView.builder(
            itemCount: categoryOptions.length,
            itemBuilder: (context, index) {
              final option = categoryOptions[index];
              final isOptionNone = option['value'] == 'none';
              final isSelected = isOptionNone ? _isNoneSelected : _selectedCategories.contains(option['value']);

              return GestureDetector(
                onTap: () => _onOptionSelected(option['value']!),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
                  padding: EdgeInsets.all(paddingValue),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey[800],
                    borderRadius: BorderRadius.circular(borderRadiusValue),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option['label']!,
                        style: TextStyle(
                          fontSize: itemFontSize,
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: heightValue),
        Center(
          child: ElevatedButton(
            onPressed: _isNoneSelected || _selectedCategories.isNotEmpty
                ? () async {
              final selectedEquipment = <String>{};

              if (_isNoneSelected) {
              } else if (_selectedCategories.contains('all')) {
                for (final equipmentList in categoryToEquipment.values) {
                  selectedEquipment.addAll(equipmentList);
                }
              } else {
                for (final category in _selectedCategories) {
                  final equipmentList = categoryToEquipment[category];
                  if (equipmentList != null) {
                    selectedEquipment.addAll(equipmentList);
                  }
                }
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('selectedEquipment', selectedEquipment.toList());

              final user = SupabaseHelper.client.auth.currentUser;
              if (user != null) {
                await SupabaseService.updateUserProfile(
                  user.id,
                  selectedGender: prefs.getString('selectedGender') ?? '',
                  selectedAge: prefs.getInt('selectedAge'),
                  selectedHeight: prefs.getDouble('selectedHeight'),
                  selectedWeight: prefs.getDouble('selectedWeight'),
                  selectedFatPercentage: prefs.getString('selectedFatPercentage') ?? '',
                  selectedEquipment: selectedEquipment.toList(),
                );
              }

              widget.onEquipmentSelected(selectedEquipment.toList());

              await prefs.setBool('isRegistrationComplete', true);

              _navigateToSplashScreen();
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
              'Завершить регистрацию',
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