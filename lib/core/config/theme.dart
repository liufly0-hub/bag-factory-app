import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF94A3B8);

  /// 工人端主题 - 超大按钮、大字体
  static ThemeData workerTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoSansSC',
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        labelStyle: const TextStyle(fontSize: 18),
        hintStyle: const TextStyle(fontSize: 18, color: textGray),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textDark),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textDark),
        bodyLarge: TextStyle(fontSize: 18, color: textDark),
        bodyMedium: TextStyle(fontSize: 16, color: textDark),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// 老板端主题
  static ThemeData bossTheme() {
    final base = workerTheme();
    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'approved': return secondary;
      case 'rejected': return danger;
      case 'pending': return warning;
      case 'completed': return secondary;
      case 'in_progress': return primary;
      case 'cancelled': return textGray;
      default: return textGray;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'approved': return '已审核';
      case 'rejected': return '已驳回';
      case 'pending': return '待审核';
      case 'completed': return '已完成';
      case 'in_progress': return '生产中';
      case 'cancelled': return '已取消';
      default: return status;
    }
  }
}
