import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'legend_item.dart';

class DonutChartCard extends StatelessWidget {
  final String title;
  final List<dynamic> data;
  final List<Color> colors;
  final String subtitle;

  const DonutChartCard({
    Key? key,
    required this.title,
    required this.data,
    required this.colors,
    this.subtitle = 'Distribution',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          isSmallScreen
              ? Column(
                children: [
                  SizedBox(height: 180, child: _buildPieChart()),
                  SizedBox(height: 12),
                  ...List.generate(
                    data.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: LegendItem(
                        title: data[index]['_id'],
                        value: data[index]['count'].toString(),
                        color: colors[index % colors.length],
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(height: 200, child: _buildPieChart()),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          data.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: LegendItem(
                              title: data[index]['_id'],
                              value: data[index]['count'].toString(),
                              color: colors[index % colors.length],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections:
            data.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return PieChartSectionData(
                color: colors[index % colors.length],
                value: (item['count'] as num).toDouble(),
                title: '',
                radius: 40,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }
}
