//lib/hub/hubthree/widgets/newexercisepage.dart
import 'dart:io';
import 'package:Elite_KA/hub/hubthree/services/exercise_service.dart';
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name = '';
  late String _bodyPart = 'Всё тело';
  late String _equipment = 'Нет';
  String? _imagePath;

  static const _bodyParts = [
    'Всё тело',
    'Грудь',
    'Мышечный каркас',
    'Ноги',
    'Плечи',
    'Руки',
    'Спина',
    'Ягодичные'
  ];
  static const _equipments = [
    'Нет',
    'Вес тела',
    'Гантели',
    'Гиря',
    'Диск штанги',
    'Штанга',
    'Горизонтальная скамья',
    'Наклонная скамья',
    'Скамья Скотта',
    'Скамья для гиперэкстензии',
    'Перекладина для подтягивания',
    'Перекладина для подтягивания с подпоркой',
    'Стойка для махов',
    'Стойка для махов с подпоркой',
    'Тренажер для жима ногами',
    'Тренажер для икроножных мышц',
    'Сидячий тренажер для бедренных мышц',
    'Тренажер для приседаний с упором',
    'Тренажер для сгибания ног',
    'Тренажер для экстензии ног',
    'Блочный тренажер',
    'Тренажер Смита',
    'Тренажер для скручивания',
    'Тренажер для дельтовидных мышц',
    'Тренажер для изолированного сгибания рук',
    'Тренажер для разведения рук',
    'Тренажер для экстензии трицепсов',
    'Наклонный тренажер для грудных мышц',
    'Тренажер для грудных мышц',
    'Тренажер для сведения рук',
    'Тренажер для тяги вертикального блока',
    'Тренажер для тяги горизонтального блока',
    'Лента с ручками',
    'Ролик для пресса',
    'Степ',
    'Фитбол',
    'Медбол',
  ];

  Future<String?> _copyImageToAppDir(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        throw Exception('Исходный файл не существует');
      }
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(originalPath);
      final newFilePath = path.join(appDir.path, 'exercise_images', fileName);
      final newFile = File(newFilePath);
      final imageDir = Directory(path.join(appDir.path, 'exercise_images'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      final copiedFile = await originalFile.copy(newFile.path);
      return copiedFile.path;
    } catch (e) {
      debugPrint('Ошибка при копировании изображения: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final copiedPath = await _copyImageToAppDir(picked.path);
      if (copiedPath != null) {
        setState(() {
          _imagePath = copiedPath;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[900],
              content: Center(
                child: Text(
                  'Ошибка при сохранении изображения',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;
    final btnPadding = isSmallScreen
        ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final verticalSpacing = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Новое упражнение',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[900],
          dropdownMenuTheme: DropdownMenuThemeData(
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.grey[900]),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: isSmallScreen ? 100 : 120,
                        height: isSmallScreen ? 100 : 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          image: _imagePath != null
                              ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _imagePath == null
                            ? Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                          size: isSmallScreen ? 28 : 32,
                        )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'ИМЯ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: labelFontSize,
                    ),
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white, fontSize: fontSize),
                    decoration: InputDecoration(
                      hintText: 'Название упражнения',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: fontSize),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Введите название' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'ЧАСТЬ ТЕЛА',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: labelFontSize,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _bodyPart,
                    items: _bodyParts.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize)),
                    )).toList(),
                    onChanged: (value) => setState(() => _bodyPart = value!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'ОБОРУДОВАНИЕ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: labelFontSize,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _equipment,
                    items: _equipments.map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 48,
                        child: Text(
                          e,
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )).toList(),
                    onChanged: (value) => setState(() => _equipment = value!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    isExpanded: true,
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final muscleGroups = _bodyPart == 'Всё тело'
                                  ? ['Всё тело']
                                  : [_bodyPart];
                              final newExercise = Exercise(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _name,
                                muscleGroups: muscleGroups,
                                equipment: _equipment,
                                image: _imagePath ?? '',
                                bodyPart: _bodyPart,
                                isCustom: true,
                              );
                              try {
                                await ExerciseService.addCustomExercise(newExercise);
                                if (context.mounted) {
                                  Navigator.pop(context, newExercise);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.grey[900],
                                      content: Center(
                                        child: Text(
                                          'Ошибка при сохранении упражнения',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            padding: btnPadding,
                          ),
                          child: Text(
                            'СОХРАНИТЬ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: Navigator.of(context).pop,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            padding: btnPadding,
                          ),
                          child: Text(
                            'ОТМЕНА',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}