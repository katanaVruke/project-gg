// lib/hub/hubone/tools.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  int _currentIndex = 0;
  Set<String> _selectedEquipment = <String>{};
  late PageController _pageController;

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Свободные веса',
      'icon': Icons.dark_mode_sharp,
      'items': [
        {'name': 'Гантели'},
        {'name': 'Гиря'},
        {'name': 'Диск штанги'},
        {'name': 'Штанга'},
      ],
    },
    {
      'title': 'Стойки и скамьи',
      'icon': Icons.chair,
      'items': [
        {'name': 'Горизонтальная скамья'},
        {'name': 'Наклонная скамья'},
        {'name': 'Скамья скотта'},
        {'name': 'Скамья для гиперэкстензии'},
        {'name': 'Перекладина для подтягиваний'},
        {'name': 'Перекладина для подтягиваний+'},
        {'name': 'Стойка для махов'},
        {'name': 'Стойка для махов с подпоркой'},
      ],
    },
    {
      'title': 'Силовые тренажёры',
      'icon': Icons.fitness_center,
      'items': [
        {'name': 'Тренажёр для жима ногами'},
        {'name': 'Тренажёр для икроножных мышц'},
        {'name': 'Сидячий тренажёр для бедёр'},
        {'name': 'Тренажёр для приседаний с упором'},
        {'name': 'Тренажёр для сгибания ног'},
        {'name': 'Тренажёр для экстензии ног'},
        {'name': 'Блочный тренажёр'},
        {'name': 'Тренажёр смита'},
        {'name': 'Тренажёр для скручивания'},
        {'name': 'Тренажёр для дельтовидных мышц'},
        {'name': 'Тренажёр для сгибания рук'},
        {'name': 'Тренажёр для разведения рук'},
        {'name': 'Тренажёр для экстензии трицепсов'},
        {'name': 'Наклонный тренажёр для груди'},
        {'name': 'Тренажёр для грудных мышц'},
        {'name': 'Тренажёр для сведения рук'},
        {'name': 'Тяга вертикального блока'},
        {'name': 'Тяга горизонтального блока'},
      ],
    },
    {
      'title': 'Прочее оборудование',
      'icon': Icons.sports_gymnastics,
      'items': [
        {'name': 'Лента с ручками'},
        {'name': 'Ролик для пресса'},
        {'name': 'Степ'},
        {'name': 'Фитбол'},
        {'name': 'Медбол'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSelectedEquipment();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedEquipment() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selectedEquipment');
    if (saved != null) {
      setState(() {
        _selectedEquipment = saved.toSet();
      });
    }
  }

  Future<void> _saveSelectedEquipment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedEquipment', _selectedEquipment.toList());
  }

  void _toggleItem(String itemName) {
    setState(() {
      if (_selectedEquipment.contains(itemName)) {
        _selectedEquipment.remove(itemName);
      } else {
        _selectedEquipment.add(itemName);
      }
    });
    _saveSelectedEquipment();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final appBarFontSize = isSmallScreen ? 18.0 : 20.0;
    final tabFontSize = isSmallScreen ? 12.0 : 14.0;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final paddingValue = isSmallScreen ? 16.0 : 20.0;
    final tabHeight = isSmallScreen ? 50.0 : 56.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final checkIconSize = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
          'Доступное оборудование',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: appBarFontSize,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: tabHeight,
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _currentIndex == index;

                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 12,
                          vertical: isSmallScreen ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.red
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category['icon'],
                              color: Colors.white,
                              size: iconSize,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              category['title'],
                              style: TextStyle(
                                fontSize: tabFontSize,
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              height: 1,
              color: Colors.grey[700],
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: categories.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final items = category['items'] as List<Map<String, dynamic>>;

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final isSelected = _selectedEquipment.contains(item['name']);

                      return GestureDetector(
                        onTap: () => _toggleItem(item['name']),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: paddingValue,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          padding: EdgeInsets.all(paddingValue),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.grey[700]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: itemFontSize,
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.red,
                                  size: checkIconSize,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(paddingValue),
              decoration: BoxDecoration(),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 30 : 40,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Обновить',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    'Выбрано ${_selectedEquipment.length}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}