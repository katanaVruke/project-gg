// lib/hub/hubFive/ingredients.dart
import 'package:Elite_KA/hub/hubfive/api_product_search.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ingredient {
  final String name;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;

  Ingredient({
    required this.name,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'kcal': kcal,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: json['name'] ?? '',
    kcal: (json['kcal'] as num?)?.toDouble() ?? 0.0,
    protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
    fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
  );
}

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  late Future<List<Ingredient>> _ingredientsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ingredientsFuture = _loadIngredients();
  }

  Future<List<Ingredient>> _loadIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('ingredients') ?? '[]';
    final List<dynamic> jsonList = (jsonDecode(jsonString) as List?) ?? [];
    return jsonList.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveIngredients(List<Ingredient> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(ingredients.map((i) => i.toJson()).toList());
    await prefs.setString('ingredients', jsonString);
  }
  Future<void> _loadIngredientsFromSupabase() async {
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        final supabaseIngredients = await SupabaseService.getUserIngredients(user.id);
        if (supabaseIngredients != null) {
          final ingredients = supabaseIngredients.map((json) => Ingredient.fromJson(json)).toList();
          await _saveIngredients(ingredients);
          if (mounted) {
            setState(() {
              _ingredientsFuture = Future.value(ingredients);
            });
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка загрузки ингредиентов из Supabase: $e');
        }
      }
    }
  }

  String _filterNumeric(String input) {
    final filtered = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = filtered.split('.');
    if (parts.length > 2) {
      return '${parts[0]}.${parts.sublist(1).join('')}';
    }
    return filtered;
  }

  void bindNumericFilter(TextEditingController ctrl) {
    ctrl.addListener(() {
      final text = ctrl.text;
      final filtered = _filterNumeric(text);
      if (text != filtered) {
        ctrl.value = TextEditingValue(
          text: filtered,
          selection: TextSelection.collapsed(offset: filtered.length),
        );
      }
    });
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    final kcalController = TextEditingController();
    final proteinController = TextEditingController();
    final fatController = TextEditingController();
    final carbsController = TextEditingController();

    [kcalController, proteinController, fatController, carbsController]
        .forEach(bindNumericFilter);

    await showDialog(
      context: context,
      builder: (ctx) {
        final isSmallScreen = MediaQuery.of(context).size.height < 700;
        final titleFontSize = isSmallScreen ? 16.0 : 18.0;
        final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
        final textFieldPadding = isSmallScreen ? 2.0 : 4.0;
        final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);

        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: dialogPadding,
                    child: Column(
                      children: [
                        Text(
                          'Редактировать',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(nameController, 'Название (RU или EN)', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(kcalController, 'Ккал на 100г', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(proteinController, 'Белки на 100г', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(fatController, 'Жиры на 100г', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(carbsController, 'Углеводы на 100г', isSmallScreen: isSmallScreen),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: dialogPadding.left,
                      right: dialogPadding.right,
                      bottom: dialogPadding.bottom,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: Navigator.of(ctx).pop,
                          child: Text('Отмена', style: TextStyle(color: Colors.grey, fontSize: buttonFontSize)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                          ),
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) return;
                            final ingredient = Ingredient(
                              name: nameController.text.trim(),
                              kcal: double.tryParse(kcalController.text) ?? 0.0,
                              protein: double.tryParse(proteinController.text) ?? 0.0,
                              fat: double.tryParse(fatController.text) ?? 0.0,
                              carbs: double.tryParse(carbsController.text) ?? 0.0,
                            );
                            Navigator.of(ctx).pop();
                            await _addIngredient(ingredient);
                          },
                          child: Text('Добавить', style: TextStyle(color: Colors.white, fontSize: buttonFontSize)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(Ingredient ingredient) async {
    final nameController = TextEditingController(text: ingredient.name);
    final kcalController = TextEditingController(text: ingredient.kcal.toString());
    final proteinController = TextEditingController(text: ingredient.protein.toString());
    final fatController = TextEditingController(text: ingredient.fat.toString());
    final carbsController = TextEditingController(text: ingredient.carbs.toString());

    [kcalController, proteinController, fatController, carbsController]
        .forEach(bindNumericFilter);

    await showDialog(
      context: context,
      builder: (ctx) {
        final isSmallScreen = MediaQuery.of(context).size.height < 700;
        final titleFontSize = isSmallScreen ? 16.0 : 18.0;
        final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
        final textFieldPadding = isSmallScreen ? 2.0 : 4.0;
        final dialogPadding = isSmallScreen ? EdgeInsets.all(12) : EdgeInsets.all(16);

        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: dialogPadding,
                    child: Column(
                      children: [
                        Text(
                          'Редактировать',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(nameController, 'Название (RU или EN)', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(kcalController, 'Ккал на 100г', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(proteinController, 'Белки на 100г', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(fatController, 'Жиры на 100г', isSmallScreen: isSmallScreen),
                        SizedBox(height: textFieldPadding),
                        _buildTextField(carbsController, 'Углеводы на 100г', isSmallScreen: isSmallScreen),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: dialogPadding.left,
                      right: dialogPadding.right,
                      bottom: dialogPadding.bottom,
                    ),
                    child: isSmallScreen
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Отмена', style: TextStyle(color: Colors.grey, fontSize: buttonFontSize)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                          ),
                          onPressed: () async {
                            final updated = Ingredient(
                              name: nameController.text.trim(),
                              kcal: double.tryParse(kcalController.text) ?? 0.0,
                              protein: double.tryParse(proteinController.text) ?? 0.0,
                              fat: double.tryParse(fatController.text) ?? 0.0,
                              carbs: double.tryParse(carbsController.text) ?? 0.0,
                            );
                            Navigator.of(ctx).pop();
                            await _updateIngredient(ingredient, updated);
                          },
                          child: Text('Сохранить', style: TextStyle(color: Colors.white, fontSize: buttonFontSize)),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Отмена', style: TextStyle(color: Colors.grey, fontSize: buttonFontSize)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _deleteIngredient(ingredient);
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 28.0,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                          ),
                          onPressed: () async {
                            final updated = Ingredient(
                              name: nameController.text.trim(),
                              kcal: double.tryParse(kcalController.text) ?? 0.0,
                              protein: double.tryParse(proteinController.text) ?? 0.0,
                              fat: double.tryParse(fatController.text) ?? 0.0,
                              carbs: double.tryParse(carbsController.text) ?? 0.0,
                            );
                            Navigator.of(ctx).pop();
                            await _updateIngredient(ingredient, updated);
                          },
                          child: Text('Сохранить', style: TextStyle(color: Colors.white, fontSize: buttonFontSize)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {required bool isSmallScreen}) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Colors.white,
        fontSize: isSmallScreen ? 12.0 : 14.0,
      ),
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey,
          fontSize: isSmallScreen ? 11.0 : 13.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _addIngredient(Ingredient ingredient) async {
    final ingredients = await _loadIngredients();
    final exists = ingredients.any(
          (existing) =>
      existing.name.trim().toLowerCase() == ingredient.name.trim().toLowerCase(),
    );
    if (exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey[900],
            content: Center(
              child: Text(
                'Ингредиент "${ingredient.name}" уже существует',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    ingredients.add(ingredient);
    await _saveIngredients(ingredients);

    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseService.addIngredient(user.id, ingredient.toJson());
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка добавления ингредиента в Supabase: $e');
        }
      }
    }

    setState(() {
      _ingredientsFuture = _loadIngredients();
    });
  }

  Future<void> _updateIngredient(Ingredient old, Ingredient updated) async {
    final ingredients = await _loadIngredients();

    if (old.name.trim().toLowerCase() != updated.name.trim().toLowerCase()) {
      final exists = ingredients.any(
            (ing) =>
        ing.name.trim().toLowerCase() == updated.name.trim().toLowerCase(),
      );
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[900],
              content: Center(
                child: Text(
                  'Ингредиент "${updated.name}" уже существует',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }
    }

    final index = ingredients.indexWhere((i) =>
    i.name == old.name &&
        i.kcal == old.kcal &&
        i.protein == old.protein &&
        i.fat == old.fat &&
        i.carbs == old.carbs);

    if (index != -1) {
      ingredients[index] = updated;
      await _saveIngredients(ingredients);

      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null) {
        try {
          await SupabaseService.updateIngredient(user.id, old.name, updated.toJson());
        } catch (e) {
          if (kDebugMode) {
            print('Ошибка обновления ингредиента в Supabase: $e');
          }
        }
      }

      setState(() {
        _ingredientsFuture = _loadIngredients();
      });
    }
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final ingredients = await _loadIngredients();
    ingredients.removeWhere((i) =>
    i.name == ingredient.name &&
        i.kcal == ingredient.kcal &&
        i.protein == ingredient.protein &&
        i.fat == ingredient.fat &&
        i.carbs == ingredient.carbs);
    await _saveIngredients(ingredients);
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseService.deleteIngredient(user.id, ingredient.name);
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка удаления ингредиента из Supabase: $e');
        }
      }
    }

    setState(() {
      _ingredientsFuture = _loadIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final subFontSize = isSmallScreen ? 10.0 : 12.0;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final containerPadding = isSmallScreen ? EdgeInsets.all(8) : EdgeInsets.all(12);
    final verticalSpacing = isSmallScreen ? 2.0 : 4.0;
    final containerMargin = isSmallScreen ? EdgeInsets.symmetric(vertical: 2) : EdgeInsets.symmetric(vertical: 4);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Ингредиенты и еда',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
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
            onPressed: _loadIngredientsFromSupabase,
          ),
        ],
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
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: isSmallScreen ? 11.0 : 13.0,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: isSmallScreen ? 18.0 : 20.0,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: paddingValue),
              SizedBox(height: verticalSpacing),
              Expanded(
                child: FutureBuilder<List<Ingredient>>(
                  future: _ingredientsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.red));
                    }

                    final allIngredients = snapshot.data!;
                    final filtered = allIngredients
                        .where((i) => i.name.toLowerCase().contains(_searchQuery))
                        .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Нет ингредиентов',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return GestureDetector(
                          onTap: () => _showEditDialog(item),
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
                                  item.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: itemFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: verticalSpacing),
                                Text(
                                  'Ккал: ${item.kcal.toStringAsFixed(1)} | '
                                      'Б: ${item.protein.toStringAsFixed(1)} | '
                                      'Ж: ${item.fat.toStringAsFixed(1)} | '
                                      'У: ${item.carbs.toStringAsFixed(1)}',
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 8,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              heroTag: null,
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            right: 80,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApiProductSearchPage(onIngredientAdded: () {
                      setState(() {
                        _ingredientsFuture = _loadIngredients();
                      });
                    }),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              heroTag: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}