// lib/hub/hubfive/api_product_search.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ingredients.dart';

class ApiProductSearchPage extends StatefulWidget {
  final VoidCallback onIngredientAdded;

  const ApiProductSearchPage({super.key, required this.onIngredientAdded});

  @override
  State<ApiProductSearchPage> createState() => _ApiProductSearchPageState();
}

class _ApiProductSearchPageState extends State<ApiProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Ingredient> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .limit(20);

      final List<dynamic> data = response as List<dynamic>;
      final List<Ingredient> results = data.map((item) {
        return Ingredient(
          name: item['name'] ?? '',
          kcal: (item['kcal'] as num?)?.toDouble() ?? 0.0,
          protein: (item['protein'] as num?)?.toDouble() ?? 0.0,
          fat: (item['fat'] as num?)?.toDouble() ?? 0.0,
          carbs: (item['carbs'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey[900]!,
            content: Center(
              child: Text(
                'Ошибка поиска: Отсутствует подключение к интернету',
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
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final itemFontSize = isSmallScreen ? 14.0 : 16.0;
    final subFontSize = isSmallScreen ? 10.0 : 12.0;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final verticalItemSpacing = isSmallScreen ? 6.0 : 8.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Поиск продуктов',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(paddingValue),
              child: TextField(
                controller: _searchController,
                onChanged: _searchProducts,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Введите название продукта...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.red))
                  : _searchResults.isEmpty
                  ? const Center(
                child: Text(
                  'Введите запрос для поиска',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: paddingValue),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: verticalItemSpacing),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 14),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: itemFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Ккал: ${item.kcal.toStringAsFixed(1)} | '
                              'Б: ${item.protein.toStringAsFixed(1)} | '
                              'Ж: ${item.fat.toStringAsFixed(1)} | '
                              'У: ${item.carbs.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: subFontSize,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: Colors.red),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final existingJson = prefs.getString('ingredients') ?? '[]';
                            final List<dynamic> existingList = jsonDecode(existingJson);
                            final List<Ingredient> existingIngredients = existingList
                                .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
                                .toList();

                            final alreadyExists = existingIngredients.any(
                                  (ing) => ing.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
                            );

                            if (alreadyExists) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.grey[900]!,
                                    content: Center(
                                      child: Text(
                                        'Ингредиент "${item.name}" уже добавлен',
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
                              return;
                            }

                            existingList.add(item.toJson());
                            await prefs.setString('ingredients', jsonEncode(existingList));

                            widget.onIngredientAdded();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.grey[900]!,
                                  content: Center(
                                    child: Text(
                                      '"${item.name}"добавлен',
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}