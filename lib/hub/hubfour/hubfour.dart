import 'dart:convert';
import 'package:Elite_KA/hub/hubfour/workout_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Elite_KA/hub/hubtwo/models/completed_workout.dart';
import 'package:Elite_KA/hub/hubtwo/services/completed_workout_storage_service.dart';

class HubFour extends StatefulWidget {
  const HubFour({super.key});

  @override
  State<HubFour> createState() => _HubFourState();
}

class _HubFourState extends State<HubFour> {
  List<String> _dayLabels = [];
  List<double> _kcalData = [], _proteinData = [], _fatData = [], _carbsData = [];
  int _maxIndex = -1, _minIndex = -1;
  String _selectedMetric = 'kcal';
  double _normKcal = 0, _normProtein = 0, _normFat = 0, _normCarbs = 0;
  String _weekRange = '';
  int _weekOffset = 0;
  List<CompletedWorkout> _workoutHistory = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadWeekData();
    _loadNormsFromHubFive();
    _loadWorkoutHistory();
  }

  DateTime _getStartOfWeek({int offset = 0}) {
    final now = DateTime.now();
    final startThisWeek = now.subtract(Duration(days: now.weekday - 1));
    return startThisWeek.add(Duration(days: offset * 7));
  }

  String _formatDateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _loadWeekData() async {
    final prefs = await SharedPreferences.getInstance();
    final start = _getStartOfWeek(offset: _weekOffset);
    List<String> labels = [];
    List<double> kcal = [], protein = [], fat = [], carbs = [];

    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final key = 'eaten_foods_${_formatDateKey(date)}';
      final jsonString = prefs.getString(key) ?? '[]';

      double dayKcal = 0, dayProtein = 0, dayFat = 0, dayCarbs = 0;
      try {
        final list = jsonDecode(jsonString) as List;
        for (final item in list) {
          final dish = EatenDish.fromJson(item as Map<String, dynamic>);
          dayKcal += dish.totalKcal;
          dayProtein += dish.totalProtein;
          dayFat += dish.totalFat;
          dayCarbs += dish.totalCarbs;
        }
      } catch (_) {}

      labels.add(['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][i]);
      kcal.add(dayKcal);
      protein.add(dayProtein);
      fat.add(dayFat);
      carbs.add(dayCarbs);
    }

    _updateExtremes(_selectedMetric);
    final end = start.add(const Duration(days: 6));
    String format(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

    setState(() {
      _dayLabels = labels;
      _kcalData = kcal;
      _proteinData = protein;
      _fatData = fat;
      _carbsData = carbs;
      _weekRange = '${format(start)} — ${format(end)}';
    });
  }

  Future<void> _loadWorkoutHistory() async {
    final workouts = await CompletedWorkoutStorageService.loadCompletedWorkouts();

    final start = _getStartOfWeek(offset: _weekOffset);
    final end = start.add(const Duration(days: 6));

    final filtered = workouts.where((w) {
      final date = DateTime(w.startTime.year, w.startTime.month, w.startTime.day);
      final weekStart = DateTime(start.year, start.month, start.day);
      final weekEnd = DateTime(end.year, end.month, end.day);
      return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
    }).toList();

    setState(() {
      _workoutHistory = filtered;
    });
  }

  void _updateExtremes(String metric) {
    List<double> data = {
      'kcal': _kcalData,
      'protein': _proteinData,
      'fat': _fatData,
      'carbs': _carbsData,
    }[metric] ?? [];

    if (data.isEmpty) {
      setState(() {
        _maxIndex = -1;
        _minIndex = -1;
      });
      return;
    }

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double minVal = data.reduce((a, b) => a < b ? a : b);
    _maxIndex = data.indexWhere((v) => v == maxVal);
    _minIndex = data.indexWhere((v) => v == minVal);
    setState(() {});
  }

  Future<void> _loadNormsFromHubFive() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _normKcal = prefs.getDouble('kcal') ?? 0;
      _normProtein = prefs.getDouble('protein') ?? 0;
      _normFat = prefs.getDouble('fat') ?? 0;
      _normCarbs = prefs.getDouble('carbs') ?? 0;
    });
  }

  void _changeWeek(int delta) {
    final newOffset = _weekOffset + delta;
    if (newOffset > 0 || newOffset < -3) return;
    setState(() {
      _weekOffset = newOffset;
    });
    _loadWeekData();
    _loadWorkoutHistory();
  }

  Future<void> _deleteWorkout(CompletedWorkout workout) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList('completed_workouts') ?? [];

      final updatedList = rawList
          .map((str) => jsonDecode(str) as Map<String, dynamic>)
          .where((json) => json['id'] != workout.id)
          .map((json) => jsonEncode(json))
          .toList();

      await prefs.setStringList('completed_workouts', updatedList);

      await _loadWorkoutHistory();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showDeleteConfirmation(CompletedWorkout workout) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Удалить тренировку?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '«${workout.workoutName}» от ${workout.formattedDate} будет удалена навсегда.',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteWorkout(workout);
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openWorkoutDetails(CompletedWorkout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final verticalSpacing = isSmallScreen ? 8.0 : 12.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isSmallScreen ? 13.0 : 15.0;
    final chartHeight = isSmallScreen ? 180.0 : 220.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Статистика за неделю',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выбор недели',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: verticalSpacing / 2),
                _buildWeekNavigator(isSmallScreen, padding),
                SizedBox(height: verticalSpacing),

                Text(
                  'График недельного КБЖУ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: verticalSpacing / 2),
                _buildChartContainer(isSmallScreen, padding, chartHeight),
                SizedBox(height: verticalSpacing),
                _buildLegendAndSummary(isSmallScreen, padding),
                SizedBox(height: verticalSpacing),

                Center(
                  child: Text(
                    'ТРЕНИРОВКИ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: verticalSpacing / 2),

                _buildWorkoutSummaryCard(isSmallScreen, padding),
                if (_workoutHistory.isNotEmpty) SizedBox(height: verticalSpacing),
                _buildWorkoutHistorySection(isSmallScreen, padding),
                SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigator(bool isSmallScreen, double padding) => Container(
    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _weekOffset > -3 ? () => _changeWeek(-1) : null,
          icon: Icon(Icons.arrow_back,
              color: _weekOffset > -3 ? Colors.white : Colors.grey,
              size: isSmallScreen ? 18 : 20),
        ),
        Text(
          _weekRange,
          style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: _weekOffset < 0 ? () => _changeWeek(1) : null,
          icon: Icon(Icons.arrow_forward,
              color: _weekOffset < 0 ? Colors.white : Colors.grey,
              size: isSmallScreen ? 18 : 20),
        ),
      ],
    ),
  );

  Widget _buildChartContainer(bool isSmallScreen, double padding, double chartHeight) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getMetricLabel(_selectedMetric),
          style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        SizedBox(height: chartHeight, child: _buildChart(isSmallScreen)),
      ],
    ),
  );

  String _getMetricLabel(String metric) => {
    'kcal': 'Калории',
    'protein': 'Белки',
    'fat': 'Жиры',
    'carbs': 'Углеводы'
  }[metric] ?? '';

  Widget _buildChart(bool isSmallScreen) {
    if (_kcalData.isEmpty) {
      return Center(
          child: Text('Нет данных за неделю',
              style: TextStyle(color: Colors.grey)));
    }

    Map<String, dynamic> cfg = {
      'kcal': {'data': _kcalData, 'color': Colors.red, 'norm': _normKcal},
      'protein': {
        'data': _proteinData,
        'color': Colors.green,
        'norm': _normProtein
      },
      'fat': {'data': _fatData, 'color': Colors.blue, 'norm': _normFat},
      'carbs': {
        'data': _carbsData,
        'color': Colors.orange,
        'norm': _normCarbs
      },
    }[_selectedMetric]!;

    List<double> data = cfg['data'];
    Color color = cfg['color'];
    double normValue = cfg['norm'];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isSmallScreen ? 20 : 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _dayLabels.length) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _dayLabels[i],
                    style: TextStyle(fontSize: isSmallScreen ? 9 : 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: false,
            color: color,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, index) {
                final val = data[index];
                Color dotColor = color;
                Color strokeColor = Colors.transparent;

                if (normValue > 0) {
                  if (val > normValue * 1.1) {
                    dotColor = Colors.black;
                    strokeColor = Colors.white;
                  } else if (val < normValue * 0.9) {
                    dotColor = Colors.white;
                    strokeColor = Colors.black;
                  } else {
                    dotColor = color;
                  }
                }

                if (index == _maxIndex || index == _minIndex) {
                  return FlDotCirclePainter(
                    radius: isSmallScreen ? 5 : 6,
                    color: color,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }

                return FlDotCirclePainter(
                  radius: isSmallScreen ? 3 : 4,
                  color: dotColor,
                  strokeWidth: 1,
                  strokeColor: strokeColor,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: _computeMaxY(data),
      ),
    );
  }

  double _computeMaxY(List<double> data) =>
      data.isEmpty ? 100 : data.reduce((a, b) => a > b ? a : b) * 1.2;

  Widget _buildLegendAndSummary(bool isSmallScreen, double padding) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: isSmallScreen ? 12 : 16,
          runSpacing: isSmallScreen ? 4 : 6,
          children: [
            _legendItem('Ккал', Colors.red, 'kcal', isSmallScreen),
            _legendItem('Б', Colors.green, 'protein', isSmallScreen),
            _legendItem('Ж', Colors.blue, 'fat', isSmallScreen),
            _legendItem('У', Colors.orange, 'carbs', isSmallScreen),
          ],
        ),
        Divider(height: isSmallScreen ? 12 : 16, color: Colors.grey[700]),
        if (_maxIndex >= 0 && _minIndex >= 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _extremeText(
                  'Максимум', _getValueAt(_maxIndex), _dayLabels[_maxIndex], _getColorForMetric(), isSmallScreen),
              _extremeText(
                  'Минимум',
                  _getValueAt(_minIndex),
                  _dayLabels[_minIndex],
                  _getColorForMetric(),
                  isSmallScreen),
            ],
          ),
      ],
    ),
  );

  Widget _legendItem(String text, Color color, String metric, bool isSmallScreen) => GestureDetector(
    onTap: () {
      setState(() => _selectedMetric = metric);
      _updateExtremes(metric);
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmallScreen ? 8 : 10,
          height: isSmallScreen ? 8 : 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        SizedBox(width: isSmallScreen ? 2 : 4),
        Text(text, style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 11 : 12)),
      ],
    ),
  );

  Widget _extremeText(String prefix, double value, String day, Color color, bool isSmallScreen) {
    String unit = _selectedMetric == 'kcal' ? 'ккал' : 'г';
    return Row(
      children: [
        Icon(Icons.fiber_manual_record, size: isSmallScreen ? 6 : 8, color: color),
        SizedBox(width: isSmallScreen ? 2 : 4),
        Text('$prefix: ${value.toStringAsFixed(1)} $unit — $day',
            style: TextStyle(color: color, fontSize: isSmallScreen ? 12 : 13)),
      ],
    );
  }

  double _getValueAt(int index) => {
    'kcal': _kcalData[index],
    'protein': _proteinData[index],
    'fat': _fatData[index],
    'carbs': _carbsData[index],
  }[_selectedMetric] ??
      0;

  Color _getColorForMetric() => {
    'kcal': Colors.red,
    'protein': Colors.green,
    'fat': Colors.blue,
    'carbs': Colors.orange,
  }[_selectedMetric] ??
      Colors.grey;

  Widget _buildWorkoutSummaryCard(bool isSmallScreen, double padding) {
    final count = _workoutHistory.length;
    if (count == 0) return const SizedBox();

    Duration totalDuration = Duration.zero;
    double totalVolume = 0.0;

    for (final w in _workoutHistory) {
      totalDuration += w.duration;
      totalVolume += w.totalVolume;
    }

    final avgDuration = Duration(
      milliseconds: (totalDuration.inMilliseconds / count).round(),
    );

    String formatDuration(Duration d) {
      final min = d.inMinutes;
      final sec = d.inSeconds % 60;
      return '$min:${sec.toString().padLeft(2, "0")}';
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Итоги недели',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryMetric(
                label: 'Тренировок',
                value: '$count',
                color: Colors.white,
                unit: '',
                isSmallScreen: isSmallScreen,
              ),
              _summaryMetric(
                label: 'Время',
                value: formatDuration(totalDuration),
                color: Colors.blue,
                unit: '',
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryMetric(
                label: 'Общий объём',
                value: totalVolume.toStringAsFixed(0),
                color: Colors.orange,
                unit: 'кг',
                isSmallScreen: isSmallScreen,
              ),
              _summaryMetric(
                label: 'В среднем',
                value: formatDuration(avgDuration),
                color: Colors.blue,
                unit: '',
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric({
    required String label,
    required String value,
    required Color color,
    required String unit,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 11 : 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistorySection(bool isSmallScreen, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'История',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_workoutHistory.isNotEmpty)
              Text(
                '${_workoutHistory.length} шт.',
                style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 11 : 13),
              ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        if (_workoutHistory.isEmpty)
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Тренировок за эту неделю нет',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ..._workoutHistory.map((workout) => _buildWorkoutCard(workout, isSmallScreen, padding)),
      ],
    );
  }

  Widget _buildWorkoutCard(CompletedWorkout workout, bool isSmallScreen, double padding) {
    final duration = workout.duration;
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);
    final durationText = '$minutes:${secs.toString().padLeft(2, "0")}';

    return GestureDetector(
      onTap: () => _openWorkoutDetails(workout),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    workout.workoutName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  workout.formattedDate,
                  style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 11 : 13),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _statBadge('⏱', durationText, Colors.blue, isSmallScreen),
                    SizedBox(width: isSmallScreen ? 6 : 10),
                    _statBadge('⚖️', '${workout.totalVolume.toStringAsFixed(0)} кг', Colors.orange, isSmallScreen),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: isSmallScreen ? 16 : 20,
                  onPressed: () => _showDeleteConfirmation(workout),
                  icon: Icon(Icons.delete_outline,
                      size: isSmallScreen ? 16 : 18,
                      color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String emoji, String text, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 10 : 12)),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class EatenDish {
  final String name;
  final double weight,
      totalKcal,
      totalProtein,
      totalFat,
      totalCarbs;

  EatenDish({
    required this.name,
    required this.weight,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
  });

  factory EatenDish.fromJson(Map<String, dynamic> json) => EatenDish(
    name: json['name'],
    weight: (json['weight'] as num).toDouble(),
    totalKcal: (json['total_kcal'] as num).toDouble(),
    totalProtein: (json['total_protein'] as num).toDouble(),
    totalFat: (json['total_fat'] as num).toDouble(),
    totalCarbs: (json['total_carbs'] as num).toDouble(),
  );
}