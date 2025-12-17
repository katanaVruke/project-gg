// lib/hub/hubFive/recepts.dart
import 'dart:convert';
import 'package:Elite_KA/hub/hubfive/ingredients.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceptsPage extends StatefulWidget {
  const ReceptsPage({super.key});

  @override
  State<ReceptsPage> createState() => _ReceptsPageState();
}

class _ReceptsPageState extends State<ReceptsPage> {
  List<Dish> _dishes = [];
  List<Ingredient> _allIngredients = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDishesAndIngredients();
  }

  Future<void> _loadDishesAndIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientsJson = prefs.getString('ingredients') ?? '[]';
    try {
      final List? ingList = jsonDecode(ingredientsJson) as List?;
      _allIngredients = (ingList ?? [])
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки ингредиентов: $e');
      }
      _allIngredients = [];
    }
    final dishesJson = prefs.getString('dishes') ?? '[]';
    try {
      final List? dishList = jsonDecode(dishesJson) as List?;
      final List<Dish> dishes = (dishList ?? [])
          .map((e) => Dish.fromJson(e as Map<String, dynamic>))
          .toList();
      if (dishes.isEmpty) {
        final user = SupabaseHelper.client.auth.currentUser;
        if (user != null) {
          try {
            final supabaseDishes = await SupabaseService.getUserDishes(user.id);
            if (supabaseDishes != null && supabaseDishes.isNotEmpty) {
              await prefs.setString('dishes', jsonEncode(supabaseDishes));
              final loadedDishes = supabaseDishes.map((json) => Dish.fromJson(json)).toList();
              setState(() {
                _dishes = loadedDishes;
              });
              return;
            }
          } catch (e) {
            if (kDebugMode) {
              print('Ошибка загрузки блюд из Supabase: $e');
            }
          }
        }
      }

      setState(() {
        _dishes = dishes;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка загрузки блюд: $e');
      }
      setState(() {
        _dishes = [];
      });
    }
  }

  Future<void> _saveDishes(List<Dish> dishes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(dishes.map((d) => d.toJson()).toList());
    await prefs.setString('dishes', jsonString);
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        final dishesData = dishes.map((dish) => dish.toJson()).toList();
        await SupabaseService.syncDishesToSupabase(user.id, dishesData);
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка синхронизации блюд в Supabase: $e');
        }
      }
    }

    await _loadDishesAndIngredients();
  }

  Future<void> _deleteDish(Dish dish) async {
    final prefs = await SharedPreferences.getInstance();
    final dishesJson = prefs.getString('dishes') ?? '[]';
    final List<dynamic> existing = jsonDecode(dishesJson);
    existing.removeWhere((d) => d['name'] == dish.name);
    await prefs.setString('dishes', jsonEncode(existing));
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseService.deleteDish(user.id, dish.name);
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка удаления блюда из Supabase: $e');
        }
      }
    }
    setState(() {
      _dishes.removeWhere((d) => d.name == dish.name);
    });
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[900]!,
              content: Center(
                child: Text(
                  'Блюдо удалено',
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
      });
    }
  }

  void _showDishDetails(Dish dish) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final textFontSize = isSmallScreen ? 12.0 : 14.0;
    final subFontSize = isSmallScreen ? 10.0 : 12.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 14.0;

    final per100 = dish.calculatePer100g(_allIngredients);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          dish.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
          ),
        ),
        content: Padding(
          padding: dialogPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ингредиенты:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: textFontSize,
                  ),
                ),
                ...dish.ingredientRefs.map((ref) {
                  final ing = _allIngredients.firstWhere(
                        (i) => i.name == ref.ingredientName,
                    orElse: () => Ingredient(name: 'Не найден', kcal: 0, protein: 0, fat: 0, carbs: 0),
                  );
                  return Text(
                    '${ing.name}: ${ref.weight} г',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textFontSize,
                    ),
                  );
                }),
                SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                Text(
                  'На 100 г:\n'
                      'Ккал: ${per100['kcal']?.toStringAsFixed(1)}\n'
                      'Б: ${per100['protein']?.toStringAsFixed(1)}\n'
                      'Ж: ${per100['fat']?.toStringAsFixed(1)}\n'
                      'У: ${per100['carbs']?.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: subFontSize,
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
              'Закрыть',
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

  Future<void> _showEditDishDialog(Dish oldDish) async {
    final nameController = TextEditingController(text: oldDish.name);
    List<DishIngredientEntry> currentEntries = oldDish.ingredientRefs.map((ref) {
      final ing = _allIngredients.firstWhere(
            (i) => i.name == ref.ingredientName,
        orElse: () => Ingredient(name: ref.ingredientName, kcal: 0, protein: 0, fat: 0, carbs: 0),
      );
      return DishIngredientEntry(ing, ref.weight);
    }).toList();

    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final listTileFontSize = isSmallScreen ? 12.0 : 14.0;
    final listTileSubFontSize = isSmallScreen ? 10.0 : 12.0;
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final buttonPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 20, vertical: 10)
        : EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final verticalSpacing = isSmallScreen ? 10.0 : 12.0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Редактировать блюдо',
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
                      controller: nameController,
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
                    SizedBox(height: verticalSpacing),
                    ElevatedButton(
                      onPressed: () async {
                        await _showIngredientPickerForEdit(context, currentEntries, setState);
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
                    SizedBox(height: verticalSpacing),
                    Expanded(
                      child: currentEntries.isEmpty
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
                        itemCount: currentEntries.length,
                        itemBuilder: (context, index) {
                          final entry = currentEntries[index];
                          final totalKcal = entry.ingredient.kcal * entry.weight / 100;
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
                                  currentEntries.removeAt(index);
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
              TextButton(
                onPressed: () async {
                  await _deleteDish(oldDish);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(
                  'Удалить',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: buttonFontSize,
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
                  if (nameController.text.trim().isEmpty || currentEntries.isEmpty) {
                    if (mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.grey[900]!,
                              content: Center(
                                child: Text(
                                  'Укажите название и хотя бы 1 ингредиент',
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
                      });
                    }
                    return;
                  }
                  final updatedRefs = currentEntries.map((entry) {
                    return DishIngredientRef(
                      ingredientName: entry.ingredient.name,
                      weight: entry.weight,
                    );
                  }).toList();

                  final updatedDish = Dish(
                    name: nameController.text.trim(),
                    ingredientRefs: updatedRefs,
                  );

                  final dishes = List<Dish>.from(_dishes);
                  dishes.removeWhere((d) => d.name == oldDish.name);
                  dishes.add(updatedDish);

                  await _saveDishes(dishes);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    if (mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.grey[900]!,
                              content: Center(
                                child: Text(
                                  'Блюдо обновлено',
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
                      });
                    }
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

  Future<void> _showIngredientPickerForEdit(
      BuildContext context,
      List<DishIngredientEntry> currentEntries,
      StateSetter setState) async {
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
                      itemCount: _allIngredients.length,
                      itemBuilder: (context, index) {
                        final ing = _allIngredients[index];
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
                            _showWeightInputForNewIngredient(context, ing, currentEntries, setState);
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

  Future<void> _showWeightInputForNewIngredient(
      BuildContext context,
      Ingredient ingredient,
      List<DishIngredientEntry> currentEntries,
      StateSetter setState) async {
    final weightController = TextEditingController();

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

    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
    final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);
    final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 20, vertical: 10) : EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final borderRadius = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;

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
                currentEntries.add(DishIngredientEntry(ingredient, weight));
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final subFontSize = isSmallScreen ? 10.0 : 12.0;
    final textFieldFontSize = isSmallScreen ? 12.0 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final containerPadding = isSmallScreen ? EdgeInsets.all(10) : EdgeInsets.all(12);
    final containerMargin = isSmallScreen ? EdgeInsets.symmetric(vertical: 2) : EdgeInsets.symmetric(vertical: 4);
    final verticalSpacing = isSmallScreen ? 12.0 : 16.0;

    List<Dish> filteredDishes = _dishes
        .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Мои блюда',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textFieldFontSize,
                ),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: labelFontSize,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: iconSize,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Expanded(
                child: _dishes.isEmpty
                    ? Center(
                  child: Text(
                    'Нет блюд',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: itemFontSize,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredDishes.length,
                  itemBuilder: (context, index) {
                    final dish = filteredDishes[index];
                    final per100 = dish.calculatePer100g(_allIngredients);
                    return GestureDetector(
                      onTap: () => _showDishDetails(dish),
                      onLongPress: () => _showEditDishDialog(dish),
                      child: Container(
                        margin: containerMargin,
                        padding: containerPadding,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dish.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: itemFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                            Text(
                              'Ккал: ${per100['kcal']?.toStringAsFixed(1)} | '
                                  'Б: ${per100['protein']?.toStringAsFixed(1)} | '
                                  'Ж: ${per100['fat']?.toStringAsFixed(1)} | '
                                  'У: ${per100['carbs']?.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: subFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dish {
  final String name;
  final List<DishIngredientRef> ingredientRefs;

  Dish({required this.name, required this.ingredientRefs});

  Map<String, double> calculatePer100g(List<Ingredient> allIngredients) {
    final List<DishIngredient> resolved = [];
    for (var ref in ingredientRefs) {
      final ing = allIngredients.firstWhere(
            (i) => i.name == ref.ingredientName,
        orElse: () => Ingredient(name: 'Не найден', kcal: 0, protein: 0, fat: 0, carbs: 0),
      );
      resolved.add(DishIngredient(ingredient: ing, weight: ref.weight));
    }

    double totalWeight = resolved.fold(0.0, (sum, di) => sum + di.weight);
    if (totalWeight == 0) return {'kcal': 0, 'protein': 0, 'fat': 0, 'carbs': 0};

    double totalKcal = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;
    for (var di in resolved) {
      double ratio = di.weight / 100.0;
      totalKcal += di.ingredient.kcal * ratio;
      totalProtein += di.ingredient.protein * ratio;
      totalFat += di.ingredient.fat * ratio;
      totalCarbs += di.ingredient.carbs * ratio;
    }

    double factor = 100.0 / totalWeight;
    return {
      'kcal': totalKcal * factor,
      'protein': totalProtein * factor,
      'fat': totalFat * factor,
      'carbs': totalCarbs * factor,
    };
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'ingredients': ingredientRefs.map((ref) => ref.toJson()).toList(),
  };

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    name: json['name'] as String? ?? '',
    ingredientRefs: (json['ingredients'] as List?)
        ?.map((e) => DishIngredientRef.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
  );
}

class DishIngredientRef {
  final String ingredientName;
  final double weight;

  DishIngredientRef({required this.ingredientName, required this.weight});

  Map<String, dynamic> toJson() => {
    'ingredient_name': ingredientName,
    'weight': weight,
  };

  factory DishIngredientRef.fromJson(Map<String, dynamic> json) => DishIngredientRef(
    ingredientName: json['ingredient_name'] as String? ?? '',
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
  );
}

class DishIngredient {
  final Ingredient ingredient;
  final double weight;

  DishIngredient({required this.ingredient, required this.weight});
}

class DishIngredientEntry {
  final Ingredient ingredient;
  final double weight;
  DishIngredientEntry(this.ingredient, this.weight);
}