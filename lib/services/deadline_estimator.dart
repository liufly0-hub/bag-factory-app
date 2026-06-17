import '../models/order_model.dart';
import '../models/production_record_model.dart';

/// 工期推算引擎
class DeadlineEstimator {
  /// 计算指定产品的日均产能（取最近7天已审核数据）
  static double calculateDailyAverage(
    String productType,
    List<ProductionRecordModel> recentRecords,
  ) {
    final filtered = recentRecords
        .where((r) =>
            r.productType == productType && r.status == 'approved')
        .toList();

    if (filtered.isEmpty) return 0;

    final totalQuantity =
        filtered.fold<int>(0, (sum, r) => sum + r.quantity);
    return totalQuantity / filtered.length;
  }

  /// 推算预计完工日期
  static DateTime? estimateCompletionDate(
    OrderModel order,
    double dailyAverage,
  ) {
    if (dailyAverage <= 0) return null;

    final remainingDays =
        (order.remainingQuantity / dailyAverage).ceil();
    return DateTime.now().add(Duration(days: remainingDays));
  }

  /// 是否逾期（预计完工日 > 交期）
  static bool isOverdue(
    OrderModel order,
    double dailyAverage,
  ) {
    final estimated = estimateCompletionDate(order, dailyAverage);
    if (estimated == null) return false;
    return estimated.isAfter(order.deadline);
  }

  /// 逾期天数
  static int overdueDays(
    OrderModel order,
    double dailyAverage,
  ) {
    final estimated = estimateCompletionDate(order, dailyAverage);
    if (estimated == null) return 0;
    return estimated.difference(order.deadline).inDays;
  }
}
