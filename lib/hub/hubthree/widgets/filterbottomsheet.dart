//lib/hub/hubthree/widgets/filterbottomsheet.dart
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String initialBodyPart;
  final Function(String) onFilterChanged;

  const FilterBottomSheet({
    super.key,
    required this.initialBodyPart,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedBodyPart;

  @override
  void initState() {
    super.initState();
    selectedBodyPart = widget.initialBodyPart;
  }

  static const _allBodyParts = [
    'Грудь',
    'Мышечный каркас',
    'Ноги',
    'Плечи',
    'Руки',
    'Спина',
    'Ягодичные',
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final isSmallScreen = mediaQuery.size.height < 700;

    final hPadding = isSmallScreen ? 12.0 : 16.0;
    final vSpace = isSmallScreen ? 12.0 : 16.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final btnPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 16, vertical: 10)
        : EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    final radius = isSmallScreen ? 16.0 : 20.0;

    final bottomSafeMargin = viewInsets.bottom > 8 ? viewInsets.bottom : 24.0;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Фильтр упражнений',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'ЗАКРЫТЬ',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: vSpace),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Область внимания',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: isSmallScreen ? 13 : 15,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Wrap(
                    spacing: isSmallScreen ? 6 : 8,
                    runSpacing: isSmallScreen ? 6 : 10,
                    children: _allBodyParts.map((part) {
                      final isActive = selectedBodyPart == part;
                      return ElevatedButton(
                        onPressed: () => setState(() => selectedBodyPart = part),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.red : Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                          ),
                          padding: btnPadding,
                        ),
                        child: Text(
                          part,
                          style: TextStyle(fontSize: fontSize, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: vSpace),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: ElevatedButton(
                onPressed: () => setState(() => selectedBodyPart = 'Всё тело'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  padding: btnPadding,
                ),
                child: Text(
                  'УБРАТЬ ФИЛЬТРЫ',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: vSpace),

            Padding(
              padding: EdgeInsets.fromLTRB(
                hPadding,
                0,
                hPadding,
                bottomSafeMargin,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFilterChanged(selectedBodyPart);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                  ),
                  child: Text(
                    'ПРИМЕНИТЬ',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}