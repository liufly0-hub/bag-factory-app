class NumberUtils {
  /// 格式化金额: 1234.5 -> "¥1,234.50"
  static String formatMoney(double amount) {
    return '¥${amount.toStringAsFixed(2)}';
  }

  /// 格式化数量: 1234 -> "1,234"
  static String formatNumber(num value) {
    if (value is int) {
      return _formatInt(value);
    }
    if (value == value.roundToDouble()) {
      return _formatInt(value.toInt());
    }
    return _formatDouble(value.toDouble());
  }

  static String _formatInt(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  static String _formatDouble(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    parts[0] = _formatInt(int.parse(parts[0]));
    return parts.join('.');
  }

  /// 百分比: 0.1234 -> "12.34%"
  static String formatPercent(double ratio) {
    return '${(ratio * 100).toStringAsFixed(1)}%';
  }

  /// 次品率: (defect / total) -> "5.0%"
  static String defectRate(int defect, int total) {
    if (total == 0) return '0%';
    return formatPercent(defect / total);
  }

  /// 进度条百分比 0~1
  static double progressRatio(int current, int total) {
    if (total <= 0) return 0;
    return (current / total).clamp(0, 1);
  }
}
