import 'package:flutter/material.dart';
import 'barCharts/horizontal_bar_chart.dart';
import 'barCharts/vertical_bar_chart.dart';

class BarChartCard extends StatelessWidget {
  final String title;
  final List<dynamic> data;
  final List<Color> gradientColors;
  final String subtitle;

  const BarChartCard({
    Key? key,
    required this.title,
    required this.data,
    required this.gradientColors,
    this.subtitle = 'Average metrics per post',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use horizontal layout when more than 4 data points
    final bool useHorizontalLayout = data.length > 4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),

          // Select chart type based on data length
          useHorizontalLayout
              ? Container(
                // Make container height dynamic based on data points
                height: _calculateDynamicHeight(),
                child: HorizontalBarChart(
                  data: data,
                  gradientColors: gradientColors,
                ),
              )
              : SizedBox(
                height: 250,
                child: VerticalBarChart(
                  data: data,
                  gradientColors: gradientColors,
                ),
              ),
        ],
      ),
    );
  }

  // Calculate appropriate height based on data length
  double _calculateDynamicHeight() {
    final int dataLength = data.length;
    // Base height + additional height per item
    final double height = 80.0 + (dataLength * 35.0);
    // Cap at min 200, max 400
    return height.clamp(200.0, 400.0);
  }
}
