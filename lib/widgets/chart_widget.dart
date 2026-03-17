import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../responsive.dart';
import '../theme/app_theme.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const ExpensePieChart(
      {super.key, required this.data, required this.colors});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.data.isEmpty) return _emptyState();

    final total =
    widget.data.values.fold(0.0, (a, b) => a + b);
    final entries = widget.data.entries.toList();
    // Slightly smaller radius on tiny screens
    final baseRadius = Responsive.isXSmall ? 45.0 : 55.0;
    final touchRadius = baseRadius + 10;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = response
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: List.generate(entries.length, (i) {
                  final isTouched = i == touchedIndex;
                  final radius =
                  isTouched ? touchRadius : baseRadius;
                  final color =
                  widget.colors[i % widget.colors.length];
                  return PieChartSectionData(
                    color: color,
                    value: entries[i].value,
                    title: isTouched
                        ? '${(entries[i].value / total * 100).toInt()}%'
                        : '',
                    radius: radius,
                    titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontCaption),
                  );
                }),
                centerSpaceRadius: Responsive.isXSmall ? 28 : 35,
                sectionsSpace: 2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final color =
              widget.colors[i % widget.colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius:
                            BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        style: TextStyle(
                            fontSize: Responsive.fontCaption,
                            color: isDark
                                ? Colors.white70
                                : Colors.black54,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          const Text('No data yet',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class MonthlyBarChart extends StatelessWidget {
  final Map<String, double> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data.isEmpty) {
      return const SizedBox(
          height: 120,
          child: Center(
              child: Text('No data',
                  style: TextStyle(color: Colors.grey))));
    }

    final entries = data.entries.toList();
    final maxY = entries
        .map((e) => e.value)
        .fold(0.0, (a, b) => a > b ? a : b);
    final barWidth = Responsive.isXSmall ? 12.0 : 16.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.25,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(entries[idx].key,
                        style: TextStyle(
                            fontSize: Responsive.fontCaption - 1,
                            color: isDark
                                ? Colors.white54
                                : Colors.black45)),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(0.06),
              strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(entries.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value,
                gradient: const LinearGradient(
                    colors: AppTheme.gradientPrimary,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter),
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class BudgetComparisonChart extends StatelessWidget {
  final Map<String, List<double>> data;
  const BudgetComparisonChart(
      {super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data.isEmpty) {
      return const SizedBox(
          height: 120,
          child: Center(
              child: Text('No data',
                  style: TextStyle(color: Colors.grey))));
    }
    final entries = data.entries.toList();
    final maxY = entries
        .map((e) => e.value[0] > e.value[1]
        ? e.value[0]
        : e.value[1])
        .fold(0.0, (a, b) => a > b ? a : b);
    final barWidth = Responsive.isXSmall ? 8.0 : 10.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.3,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < entries.length) {
                  final lbl = entries[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        lbl.substring(
                            0, lbl.length > 5 ? 5 : lbl.length),
                        style: TextStyle(
                            fontSize: Responsive.fontCaption - 1,
                            color: isDark
                                ? Colors.white54
                                : Colors.black45)),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(entries.length, (i) {
          return BarChartGroupData(
            x: i,
            groupVertically: false,
            barRods: [
              BarChartRodData(
                toY: entries[i].value[0],
                color: AppTheme.primary.withOpacity(0.6),
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: entries[i].value[1],
                color: entries[i].value[1] > entries[i].value[0]
                    ? AppTheme.error
                    : AppTheme.success,
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ],
            barsSpace: 3,
          );
        }),
      ),
    );
  }
}