// lib/hub/hubFive/food.dart
import 'dart:convert';
import 'package:Elite_KA/Hub/HubFive/ingredients.dart';
import 'package:Elite_KA/hub/hubfive/recepts.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final List<DishIngredientEntry> _currentDishIngredients = [];
  final TextEditingController _dishNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<EatenDish> _currentDayEatenFoods = [];

  @override
  void initState() {
    super.initState();
    _loadIngredientsFromSupabaseIfNeeded();
    _loadEatenFoodsForDate(_selectedDate);
  }

  Future<void> _loadIngredientsFromSupabaseIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson = prefs.getString('ingredients') ?? '[]';
    final List<dynamic> list = jsonDecode(ingredientsJson);

    if (list.isEmpty) {
      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null) {
        try {
          final supabaseIngredients = await SupabaseService.getUserIngredients(user.id);
          if (supabaseIngredients != null && supabaseIngredients.isNotEmpty) {
            final ingredients = supabaseIngredients.map((json) => Ingredient.fromJson(json)).toList();
            await prefs.setString('ingredients', jsonEncode(ingredients.map((i) => i.toJson()).toList()));
          }
        } catch (e) {
          if (kDebugMode) {
            print('Ошибка загрузки ингредиентов из Supabase: $e');
          }
        }
      }
    }
  }

  Future<void> _loadDataFromSupabase() async {
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        final supabaseDishes = await SupabaseService.getUserDishes(user.id);
        if (supabaseDishes != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('dishes', jsonEncode(supabaseDishes));
        }
        final formattedDate = _formatDate(_selectedDate);
        final supabaseEatenFoods = await SupabaseService.getEatenDishesForDate(user.id, formattedDate);
        if (supabaseEatenFoods != null) {
          final eatenFoods = supabaseEatenFoods.map((json) => EatenDish.fromJson(json)).toList();
          await _saveEatenFoodsForDate(_selectedDate, eatenFoods);
          setState(() {
            _currentDayEatenFoods = eatenFoods;
          });
        }

        final supabaseIngredients = await SupabaseService.getUserIngredients(user.id);
        if (supabaseIngredients != null) {
          final ingredients = supabaseIngredients.map((json) => Ingredient.fromJson(json)).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ingredients', jsonEncode(ingredients.map((i) => i.toJson()).toList()));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[900]!,
              content: Center(
                child: Text(
                  'Данные синхронизированы',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка загрузки данных из Supabase: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[900]!,
              content: Center(
                child: Text(
                  'Ошибка синхронизации',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 12, vertical: 12) : EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final todayContainerPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(padding);
    final verticalSpacing = isSmallScreen ? 12.0 : 20.0;
    final rowSpacing = isSmallScreen ? 6.0 : 8.0;
    final formattedDate = "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}";
    final totalKcal = _currentDayEatenFoods.fold(0.0, (sum, dish) => sum + dish.totalKcal);
    final totalProtein = _currentDayEatenFoods.fold(0.0, (sum, dish) => sum + dish.totalProtein);
    final totalFat = _currentDayEatenFoods.fold(0.0, (sum, dish) => sum + dish.totalFat);
    final totalCarbs = _currentDayEatenFoods.fold(0.0, (sum, dish) => sum + dish.totalCarbs);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Дневник питания',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDataFromSupabase,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: todayContainerPadding,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Дата: $formattedDate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16.0 : 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Expanded(
                child: _currentDayEatenFoods.isEmpty
                    ? Center(
                  child: Text(
                    'Нет записей о съеденных блюдах',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: _currentDayEatenFoods.length,
                  itemBuilder: (context, index) {
                    final dish = _currentDayEatenFoods[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          dish.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dish.weight} г → ${dish.totalKcal.toStringAsFixed(1)} ккал',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              'Б: ${(dish.totalProtein).toStringAsFixed(1)}г Ж: ${(dish.totalFat).toStringAsFixed(1)}г У: ${(dish.totalCarbs).toStringAsFixed(1)}г',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeEatenDish(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: verticalSpacing),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    _showSelectExistingDish(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.all(16),
                  ),
                  child: Icon(Icons.add, size: 24),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Всего за день:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Divider(color: Colors.grey[600], height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ккал:',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              totalKcal.toStringAsFixed(1),
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Б:',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              '${totalProtein.toStringAsFixed(1)}г',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ж:',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              '${totalFat.toStringAsFixed(1)}г',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'У:',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              '${totalCarbs.toStringAsFixed(1)}г',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _showAddDishMenu(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: buttonPadding,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                      ),
                      child: Text(
                        'Добавить блюдо',
                        style: TextStyle(fontSize: buttonFontSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: rowSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IngredientsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: buttonPadding,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                      ),
                      child: Text(
                        'Ингредиенты и еда',
                        style: TextStyle(fontSize: buttonFontSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadEatenFoodsForDate(_selectedDate);
    }
  }

  Future<void> _loadEatenFoodsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'eaten_foods_${_formatDate(date)}';
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);

    if (list.isEmpty) {
      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null) {
        try {
          final supabaseEatenFoods = await SupabaseService.getEatenDishesForDate(user.id, _formatDate(date));
          if (supabaseEatenFoods != null && supabaseEatenFoods.isNotEmpty) {
            await prefs.setString(key, jsonEncode(supabaseEatenFoods));
            _currentDayEatenFoods = supabaseEatenFoods.map((json) => EatenDish.fromJson(json)).toList();
            setState(() {});
            return;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Ошибка загрузки съеденных блюд из Supabase: $e');
          }
        }
      }
    }

    _currentDayEatenFoods = list
        .map((e) => EatenDish.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {});
  }

  Future<void> _saveEatenFoodsForDate(DateTime date, List<EatenDish> foods) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'eaten_foods_${_formatDate(date)}';
    final jsonString = jsonEncode(foods.map((dish) => dish.toJson()).toList());
    await prefs.setString(key, jsonString);
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        final foodsData = foods.map((dish) => {
          ...dish.toJson(),
          'date': _formatDate(date),
        }).toList();
        await SupabaseService.syncEatenDishesForDateToSupabase(user.id, _formatDate(date), foodsData);
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка синхронизации съеденных блюд в Supabase: $e');
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _showAddDishMenu(BuildContext context) async {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonHeight = isSmallScreen ? 50.0 : 56.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 24, vertical: 14) : EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Добавить блюдо',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    minimumSize: Size(double.maxFinite, buttonHeight),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showCreateDishDialog(context);
                  },
                  child: Text(
                    'Создать блюдо',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10.0 : 12.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
                    minimumSize: Size(double.maxFinite, buttonHeight),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReceptsPage()),
                    );
                  },
                  child: Text(
                    'Мои блюда',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Colors.grey,
                fontSize: buttonFontSize * 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectExistingDish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final dishesJson = prefs.getString('dishes') ?? '[]';
    final List<dynamic> dishList = jsonDecode(dishesJson);
    final List<SavedDish> dishes = dishList
        .map((e) => SavedDish.fromJson(e as Map<String, dynamic>))
        .toList();
    final ingredientsJson = prefs.getString('ingredients') ?? '[]';
    final List<dynamic> ingredientList = jsonDecode(ingredientsJson);
    final List<Ingredient> ingredients = ingredientList
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<dynamic> combinedItems = [];
    for (var dish in dishes) {
      combinedItems.add({
        'type': 'dish',
        'name': dish.name,
        'data': dish,
      });
    }
    for (var ing in ingredients) {
      combinedItems.add({
        'type': 'ingredient',
        'name': ing.name,
        'data': ing,
      });
    }

    if (combinedItems.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey[900]!,
            content: Center(
              child: Text(
                'Нет сохранённых блюд и ингедиентов',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    if (context.mounted) {
      final isSmallScreen = MediaQuery
          .of(context)
          .size
          .height < 700;
      final dialogWidth = isSmallScreen ? 300.0 : 350.0;
      final dialogHeight = isSmallScreen ? 350.0 : 400.0;
      final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
      final labelFontSize = isSmallScreen ? 11.0 : 13.0;
      final listTileFontSize = isSmallScreen ? 12.0 : 14.0;
      final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
      String searchQuery = '';

      await showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Выберите блюдо или ингредиент',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16.0 : 18.0,
                ),
              ),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Поиск по названию...',
                        hintStyle: TextStyle(fontSize: labelFontSize),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: isSmallScreen ? 18.0 : 20.0,
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textFieldFontSize,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: combinedItems.length,
                        itemBuilder: (context, index) {
                          final item = combinedItems[index];
                          if (searchQuery.isNotEmpty &&
                              !item['name'].toLowerCase().contains(
                                  searchQuery)) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            title: Text(
                              item['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: listTileFontSize,
                              ),
                            ),
                            subtitle: Text(
                              item['type'] == 'dish' ? 'Блюдо' : 'Ингредиент',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: listTileFontSize * 0.9,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _showWeightInputForCombinedItem(
                                  context, item['type'], item['data']);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }


  Future<void> _showWeightInputForCombinedItem(
      BuildContext context, String itemType, dynamic itemData) async {
    final weightController = TextEditingController();
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 20, vertical: 10) : EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;

    weightController.addListener(() {
      final text = weightController.text;
      final filtered = text.replaceAll(RegExp(r'[^0-9.]'), '');
      final parts = filtered.split('.');
      if (parts.length > 2) {
        weightController.value = TextEditingValue(
          text: '${parts[0]}.${parts.sublist(1).join('')}',
          selection: TextSelection.collapsed(offset: filtered.length),
        );
      }
    });

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Вес: ${itemData.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
          ),
        ),
        content: Padding(
          padding: dialogPadding,
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d?')),
            ],
            style: TextStyle(
              color: Colors.white,
              fontSize: textFieldFontSize,
            ),
            decoration: InputDecoration(
              labelText: 'Граммы',
              labelStyle: TextStyle(
                color: Colors.grey,
                fontSize: labelFontSize,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Colors.grey,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: () async {
              final weightText = weightController.text.trim();
              if (weightText.isEmpty) return;
              final weight = double.tryParse(weightText) ?? 0.0;
              if (weight <= 0) return;

              double consumedKcal = 0;
              double consumedProtein = 0;
              double consumedFat = 0;
              double consumedCarbs = 0;

              if (itemType == 'dish') {
                final dish = itemData as SavedDish;
                final prefs = await SharedPreferences.getInstance();
                final ingredientsJson = prefs.getString('ingredients') ?? '[]';
                final List<dynamic> list = jsonDecode(ingredientsJson);
                final Map<String, Ingredient> ingredientMap = {};
                for (var e in list) {
                  final ing = Ingredient.fromJson(e as Map<String, dynamic>);
                  ingredientMap[ing.name] = ing;
                }

                double totalKcal = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;
                for (var ingEntry in dish.ingredients) {
                  final ingredient = ingredientMap[ingEntry.ingredientName];
                  if (ingredient != null) {
                    final ratio = ingEntry.weight / 100.0;
                    totalKcal += ingredient.kcal * ratio;
                    totalProtein += ingredient.protein * ratio;
                    totalFat += ingredient.fat * ratio;
                    totalCarbs += ingredient.carbs * ratio;
                  }
                }

                double totalWeightOfRecipe = dish.ingredients.fold(0.0, (sum, e) => sum + e.weight);
                if (totalWeightOfRecipe > 0) {
                  double factor = 100.0 / totalWeightOfRecipe;
                  totalKcal *= factor;
                  totalProtein *= factor;
                  totalFat *= factor;
                  totalCarbs *= factor;
                } else {
                  totalKcal = 0;
                  totalProtein = 0;
                  totalFat = 0;
                  totalCarbs = 0;
                }

                consumedKcal = totalKcal * weight / 100.0;
                consumedProtein = totalProtein * weight / 100.0;
                consumedFat = totalFat * weight / 100.0;
                consumedCarbs = totalCarbs * weight / 100.0;
              } else if (itemType == 'ingredient') {
                final ingredient = itemData as Ingredient;
                consumedKcal = ingredient.kcal * weight / 100.0;
                consumedProtein = ingredient.protein * weight / 100.0;
                consumedFat = ingredient.fat * weight / 100.0;
                consumedCarbs = ingredient.carbs * weight / 100.0;
              }

              final eatenDish = EatenDish(
                name: itemData.name,
                weight: weight,
                totalKcal: consumedKcal,
                totalProtein: consumedProtein,
                totalFat: consumedFat,
                totalCarbs: consumedCarbs,
              );

              _currentDayEatenFoods.add(eatenDish);
              await _saveEatenFoodsForDate(_selectedDate, _currentDayEatenFoods);
              setState(() {});
              if (context.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            child: Text(
              'Добавить',
              style: TextStyle(
                color: Colors.white,
                fontSize: buttonFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeEatenDish(int index) async {
    _currentDayEatenFoods.removeAt(index);
    await _saveEatenFoodsForDate(_selectedDate, _currentDayEatenFoods);
    setState(() {});
  }

  Future<void> _showCreateDishDialog(BuildContext context) async {
    _currentDishIngredients.clear();
    _dishNameController.clear();

    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final listTileFontSize = isSmallScreen ? 12.0 : 14.0;
    final listTileSubFontSize = isSmallScreen ? 10.0 : 12.0;
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 20, vertical: 10) : EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Новое блюдо',
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding: dialogPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _dishNameController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textFieldFontSize,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Название блюда',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: labelFontSize,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10.0 : 12.0),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final ingredientsJson = prefs.getString('ingredients') ?? '[]';
                        final List<dynamic> list = jsonDecode(ingredientsJson);
                        final List<Ingredient> allIngredients = list
                            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
                            .toList();
                        if (context.mounted) {
                          await _showIngredientPicker(
                              context, allIngredients, setState);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: buttonPadding,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                      child: Text(
                        'Ингредиенты',
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10.0 : 12.0),
                    Expanded(
                      child: _currentDishIngredients.isEmpty
                          ? Center(
                        child: Text(
                          'Нет ингредиентов',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: listTileFontSize,
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: _currentDishIngredients.length,
                        itemBuilder: (context, index) {
                          final entry = _currentDishIngredients[index];
                          final per100 = entry.ingredient;
                          final totalKcal = per100.kcal * entry.weight / 100;
                          return ListTile(
                            title: Text(
                              entry.ingredient.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: listTileFontSize,
                              ),
                            ),
                            subtitle: Text(
                              '${entry.weight} г → ${totalKcal.toStringAsFixed(1)} ккал',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: listTileSubFontSize,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: isSmallScreen ? 20.0 : 24.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentDishIngredients.remove(entry);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: buttonFontSize * 0.9,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                onPressed: () async {
                  if (_dishNameController.text.trim().isEmpty ||
                      _currentDishIngredients.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.grey[900]!,
                        content: Center(
                          child: Text(
                            'Укажите название и хотя бы один игредиент',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  double totalWeight = _currentDishIngredients.fold(0.0, (sum, e) => sum + e.weight);
                  if (totalWeight <= 0) return;

                  for (var entry in _currentDishIngredients) {
                    double _ = entry.weight / 100.0;
                  }

                  double _ = 100.0 / totalWeight;

                  final prefs = await SharedPreferences.getInstance();
                  final dishesJson = prefs.getString('dishes') ?? '[]';
                  final List<dynamic> existing = jsonDecode(dishesJson);
                  final newDish = {
                    'name': _dishNameController.text.trim(),
                    'ingredients': _currentDishIngredients
                        .map((e) => {
                      'ingredient_name': e.ingredient.name,
                      'weight': e.weight,
                    })
                        .toList(),
                  };

                  existing.add(newDish);
                  await prefs.setString('dishes', jsonEncode(existing));
                  final user = SupabaseHelper.client.auth.currentUser;
                  if (user != null) {
                    try {
                      final dishesData = existing.map((e) => e as Map<String, dynamic>).toList();
                      await SupabaseService.syncDishesToSupabase(user.id, dishesData);
                    } catch (e) {
                      if (kDebugMode) {
                        print('Ошибка синхронизации блюд в Supabase: $e');
                      }
                    }
                  }
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.grey[900]!,
                        content: Center(
                          child: Text(
                            'Блюдо сохранено',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(
                  'Сохранить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: buttonFontSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showIngredientPicker(
      BuildContext context, List<Ingredient> ingredients, StateSetter setState) async {
    String searchQuery = '';

    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final dialogWidth = isSmallScreen ? 300.0 : 350.0;
    final dialogHeight = isSmallScreen ? 350.0 : 400.0;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final listTileFontSize = isSmallScreen ? 12.0 : 14.0;
    final listTileSubFontSize = isSmallScreen ? 10.0 : 12.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 14.0;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Выберите ингредиент',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16.0 : 18.0,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, dialogSetState) {
            return SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      dialogSetState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Поиск по названию...',
                      hintStyle: TextStyle(fontSize: labelFontSize),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: isSmallScreen ? 18.0 : 20.0,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textFieldFontSize,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final ing = ingredients[index];
                        if (searchQuery.isNotEmpty &&
                            !ing.name.toLowerCase().contains(searchQuery)) {
                          return const SizedBox.shrink();
                        }
                        return ListTile(
                          title: Text(
                            ing.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: listTileFontSize,
                            ),
                          ),
                          subtitle: Text(
                            'Ккал: ${ing.kcal.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: listTileSubFontSize,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showWeightInput(context, ing, setState);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: buttonFontSize,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IngredientsPage()),
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showWeightInput(
      BuildContext context, Ingredient ingredient, StateSetter setState) async {
    final weightController = TextEditingController();

    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 20, vertical: 10) : EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;

    weightController.addListener(() {
      final text = weightController.text;
      final filtered = text.replaceAll(RegExp(r'[^0-9.]'), '');
      final parts = filtered.split('.');
      if (parts.length > 2) {
        weightController.value = TextEditingValue(
          text: '${parts[0]}.${parts.sublist(1).join('')}',
          selection: TextSelection.collapsed(offset: filtered.length),
        );
      }
    });

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Вес: ${ingredient.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
          ),
        ),
        content: Padding(
          padding: dialogPadding,
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d?')),
            ],
            style: TextStyle(
              color: Colors.white,
              fontSize: textFieldFontSize,
            ),
            decoration: InputDecoration(
              labelText: 'Граммы',
              labelStyle: TextStyle(
                color: Colors.grey,
                fontSize: labelFontSize,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Colors.grey,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: () {
              final weightText = weightController.text.trim();
              if (weightText.isEmpty) return;
              final weight = double.tryParse(weightText) ?? 0.0;
              if (weight <= 0) return;

              setState(() {
                _currentDishIngredients.add(DishIngredientEntry(ingredient, weight));
              });
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Добавить',
              style: TextStyle(
                color: Colors.white,
                fontSize: buttonFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DishIngredientEntry {
  final Ingredient ingredient;
  final double weight;

  DishIngredientEntry(this.ingredient, this.weight);
}

class SavedDish {
  final String name;
  final List<DishIngredient> ingredients;

  SavedDish({required this.name, required this.ingredients});

  factory SavedDish.fromJson(Map<String, dynamic> json) {
    return SavedDish(
      name: json['name'] as String? ?? '',
      ingredients: (json['ingredients'] as List?)
          ?.map((e) => DishIngredient.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class DishIngredient {
  final String ingredientName;
  final double weight;

  DishIngredient({required this.ingredientName, required this.weight});

  factory DishIngredient.fromJson(Map<String, dynamic> json) {
    return DishIngredient(
      ingredientName: json['ingredient_name'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EatenDish {
  final String name;
  final double weight;
  final double totalKcal;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;

  EatenDish({
    required this.name,
    required this.weight,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'weight': weight,
    'total_kcal': totalKcal,
    'total_protein': totalProtein,
    'total_fat': totalFat,
    'total_carbs': totalCarbs,
  };

  factory EatenDish.fromJson(Map<String, dynamic> json) {
    return EatenDish(
      name: json['name'] as String? ?? json['dish_name'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      totalKcal: (json['total_kcal'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['total_carbs'] as num?)?.toDouble() ?? 0.0,
    );
  }
}