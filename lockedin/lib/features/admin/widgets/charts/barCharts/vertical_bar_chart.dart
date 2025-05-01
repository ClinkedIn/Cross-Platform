import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../utils/chart_utils.dart';

class VerticalBarChart extends StatelessWidget {
  final List<dynamic> data;
  final List<Color> gradientColors;

  const VerticalBarChart({
    Key? key,
    required this.data,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: ChartUtils.getMaxY(data),
        minY: 0,
        barTouchData: _buildBarTouchData(),
        titlesData: _buildTitlesData(),
        gridData: _buildGridData(),
        borderData: FlBorderData(show: false),
        barGroups: _createBarGroups(),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueAccent,
        tooltipRoundedRadius: 8,
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final index = group.x.toInt();
          if (index < data.length) {
            final label = data[index]['_id'];
            final value = rod.toY.toInt();
            return BarTooltipItem(
              '$label\n',
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              children: [
                TextSpan(
                  text: '$value',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            );
          }
          return null;
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < data.length) {
              final String label = data[index]['_id'].toString();
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  ChartUtils.truncateWithEllipsis(label, 10),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _calculateYAxisInterval(),
          reservedSize: 40,
          getTitlesWidget:
              (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _calculateYAxisInterval(),
      getDrawingHorizontalLine:
          (value) => FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (item['count'] as num).toDouble(),
            width: _calculateBarWidth(),
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: ChartUtils.getMaxY(data),
              color: Colors.grey.withOpacity(0.05),
            ),
          ),
        ],
      );
    }).toList();
  }

  // Calculate appropriate bar width based on data length
  double _calculateBarWidth() {
    if (data.length <= 3) return 22; // Wider bars for few data points
    return 18; // Medium width for 4 data points
  }

  // Calculate appropriate Y-axis interval
  double _calculateYAxisInterval() {
    final maxY = ChartUtils.getMaxY(data);
    if (maxY <= 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    if (maxY <= 500) return 50;
    if (maxY <= 1000) return 100;
    return (maxY / 10).ceilToDouble();
  }
}
