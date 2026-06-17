import '../models/production_record_model.dart';
import '../models/salary_setting_model.dart';

/// 薪酬计算引擎
class WageCalculator {
  /// 计算单条记录的计件工资
  /// 工资 = 良品数量 × 产品单价
  static double calculateRecordWage(
    ProductionRecordModel record,
    SalarySettingModel setting,
  ) {
    final goodQuantity = record.quantity - record.defectQuantity;
    return goodQuantity * setting.pieceWage;
  }

  /// 计算日薪：汇总当天所有已审核记录
  static double calculateDailyWage(
    List<ProductionRecordModel> records,
    Map<String, SalarySettingModel> settings,
  ) {
    double total = 0;
    for (final record in records.where((r) => r.status == 'approved')) {
      final setting = settings[record.productType];
      if (setting != null) {
        total += calculateRecordWage(record, setting);
      }
    }
    return total;
  }

  /// 计算周薪
  static double calculateWeeklyWage(
    List<List<ProductionRecordModel>> dailyRecords, // 7天的数据
    Map<String, SalarySettingModel> settings,
  ) {
    double total = 0;
    for (final day in dailyRecords) {
      total += calculateDailyWage(day, settings);
    }
    return total;
  }

  /// 计算月薪
  static double calculateMonthlyWage(
    List<ProductionRecordModel> records,
    Map<String, SalarySettingModel> settings,
  ) {
    return calculateDailyWage(records, settings);
  }

  /// 格式化金额
  static String formatWage(double wage) {
    return '¥${wage.toStringAsFixed(2)}';
  }
}
