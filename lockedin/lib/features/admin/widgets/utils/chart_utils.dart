class ChartUtils {
  static double getMaxY(List<dynamic> data) {
    final counts = data.map((e) => (e['count'] as num).toDouble()).toList();
    final max = counts.isNotEmpty ? counts.reduce((a, b) => a > b ? a : b) : 10;
    return (max * 1.2).ceilToDouble(); // Add padding to top
  }

  static String formatNumber(dynamic number) {
    if (number is int && number >= 1000) {
      double num = number / 1000;
      return '${num.toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String truncateWithEllipsis(String text, int maxLength) {
    return (text.length <= maxLength)
        ? text
        : '${text.substring(0, maxLength)}...';
  }
}
